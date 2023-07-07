//
//  NfcService.swift
//  WatchaGot
//
//  Created by Julian Worden on 6/17/23.
//

import CoreNFC

final class NfcService: NSObject, NFCNDEFReaderSessionDelegate {
    static let shared = NfcService()

    override private init() { }
    
    /// The session that hosts all of the work performed by `NfcService`.
    var nfcSession: NFCNDEFReaderSession?
    /// The action that will be performed by `nfcSession`.
    var action: NfcAction?
    
    /// The first alert message shown when the `nfcSession` is displayed.
    var firstNfcSessionAlertMessage: String {
        switch action {
        case .write(_):
            return "Hold your phone near an empty NFC tag"
        case .delete(let item), .update(let item):
            return "Hold your phone next to the NFC tag storing data for \(item.name)."
        default:
            return ""
        }
    }
    
    /// Begins the `nfcSession` by initializing an `NFCNDEFReaderSession`.
    /// - Parameter action: The action that the `nfcSession` will perform.
    func startScanning(withAction action: NfcAction) throws {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NfcError.scanningNotSupported
        }

        self.action = action

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = firstNfcSessionAlertMessage
        nfcSession?.begin()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [NFCNDEFTag]) {
        guard tags.count == 1 else {
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = NfcError.moreThanOneTagDetected.localizedDescription
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                session.restartPolling()
            }
            return
        }

        let tag = tags.first!
        connectSessionToTag(connect: session, to: tag) { [weak self] error in
            guard error == nil else {
                self?.handleError(error!)
                return
            }

            return
        }
    }
    
    /// Writes a given `Item`'s data to a given `NFCNDEFTag`. This method will only complete successfully if the `tag` is empty.
    /// - Parameters:
    ///   - item: The item to be written to the `tag`.
    ///   - tag: The tag that will receive the `item`'s data.
    func write(_ item: Item, to tag: NFCNDEFTag) {
        checkIfTagIsEmpty(tag) { [weak self] isEmpty, _, error in
            guard error == nil else {
                self?.handleError(.unknown(error: error!))
                return
            }

            guard let isEmpty,
                  isEmpty == true else {
                self?.handleError(.tagIsNotEmpty)
                return
            }

            var updatedItem = item
            updatedItem.addTag()

            self?.writeNdefMessageToTag(write: updatedItem, to: tag) { error in
                guard error == nil else {
                    self?.handleError(error!)
                    return
                }

                DatabaseService.shared.updateData(update: updatedItem, at: Constants.apiItemsUrl) { _, error in
                    guard error == nil else {
                        self?.handleError(NfcError.databaseUpdateFailed)
                        return
                    }

                    self?.invalidateSuccessfulSession(
                        invalidate: self?.nfcSession,
                        withAlertMessage: "Database update successful.",
                        and: .write(item: updatedItem)
                    )
                }
            }
        }
    }

    func update(_ itemToEdit: Item, on tag: NFCNDEFTag) {
        checkIfTagIsEmpty(tag) { [weak self] tagIsEmpty, itemOnTag, error in
            guard error == nil else {
                self?.handleError(.unknown(error: error!))
                return
            }

            guard let tagIsEmpty,
                  tagIsEmpty == false,
                  let itemOnTag else {
                self?.handleError(.tagIsEmpty)
                return
            }

            guard itemOnTag.id == itemToEdit.id else {
                self?.handleError(.readingUnexpectedItemFromTag(expectedItem: itemToEdit, foundItem: itemOnTag))
                return
            }

            self?.writeNdefMessageToTag(write: itemToEdit, to: tag) { error in
                guard error == nil else {
                    self?.handleError(error!)
                    return
                }
                
                self?.invalidateSuccessfulSession(
                    invalidate: self?.nfcSession,
                    withAlertMessage: "Item Data Updated Successfully",
                    and: .update(item: itemToEdit)
                )
            }
        }
    }

    /// Deletes a given `Item`'s data from a given `NFCNDEFTag`. This method will only complete successfully if the `tag` is not empty.
    /// - Parameters:
    ///   - itemToDelete: The item to delete from the `tag`.
    ///   - tag: The tag that will have `itemToDelete`'s data deleted from it.
    func delete(_ itemToDelete: Item, from tag: NFCNDEFTag) {
        checkIfTagIsEmpty(tag) { [weak self] tagIsEmpty, itemOnTag, error in
            guard error == nil else {
                self?.handleError(.unknown(error: error!))
                return
            }
            
            guard let tagIsEmpty,
                  tagIsEmpty == false,
                  let itemOnTag else {
                self?.handleError(.tagIsEmpty)
                return
            }

            guard itemOnTag.id == itemToDelete.id else {
                self?.handleError(.readingUnexpectedItemFromTag(expectedItem: itemToDelete, foundItem: itemOnTag))
                return
            }

            self?.writeEmptyNdefMessageToTag(tag, for: itemToDelete) { error in
                guard error == nil else {
                    self?.handleError(error!)
                    return
                }

                self?.invalidateSuccessfulSession(
                    invalidate: self?.nfcSession,
                    withAlertMessage: "Delete successful, this NFC tag is now empty.",
                    and: .delete(item: itemToDelete)
                )
            }
        }
    }
    
    /// Connects a given `NFCNDEFReaderSession` to a given `NFCNDEFTag`. If a connection is successfully established, this method will evaluate
    /// which `NfcService` method it should run depending on the value of `action`.
    /// - Parameters:
    ///   - session: The session to connect to the `tag`.
    ///   - tag: The tag to which the `session` will attempt a connection.
    ///   - completion: Code to run when this method either successfully connects  the `tag` to the `session` or fails due to an error.
    func connectSessionToTag(connect session: NFCNDEFReaderSession, to tag: NFCNDEFTag, completion: @escaping (NfcError?) -> Void) {
        session.connect(to: tag) { [weak self] error in
            guard error == nil else {
                completion(.connectionFailed)
                return
            }

            tag.queryNDEFStatus { ndefStatus, capacity, error in
                guard error == nil else {
                    self?.handleError(.statusQueryFailed)
                    return
                }

                switch (ndefStatus, self?.action) {
                case (.notSupported, _):
                    completion(.unsupportedTag)
                case (.readWrite, .write(let item)):
                    self?.write(item, to: tag)
                case (.readWrite, .delete(let item)):
                    self?.delete(item, from: tag)
                case (.readWrite, .update(let item)):
                    self?.update(item, on: tag)
                case (.readOnly, _):
                    completion(.tagIsReadOnly)
                default:
                    completion(.unknownNdefStatus)
                }
            }
        }
    }
    
    /// Attempts to write a given `Item`'s data to a given `NFCNDEFTag`. If this method completes successfully, the given `Item`'s data will be written to
    /// the given `NFCNDEFTag` as an `NFCNDEFMessage`.
    /// - Parameters:
    ///   - item: The item to write to the tag.
    ///   - tag: The tag on which the `item`'s data will be written.
    ///   - completion: Code to run when this method either successfully writes the `item`'s data to the `tag` or fails due to an error.
    func writeNdefMessageToTag(write item: Item, to tag: NFCNDEFTag, completion: @escaping (NfcError?) -> Void) {
        guard let itemJson = try? JSONEncoder().encode(item) else {
            completion(.jsonEncodingFailed)
            return
        }

        let ndefPayload = NFCNDEFPayload(
            format: .unknown,
            type: Data(),
            identifier: Data(),
            payload: itemJson
        )

        let ndefMessage = NFCNDEFMessage(records: [ndefPayload])

        tag.writeNDEF(ndefMessage) { [weak self] error in
            guard error == nil else {
                completion(.writeFailed)
                print(error!)
                return
            }

            self?.nfcSession?.alertMessage = "This item's data has been successfully written to your NFC tag. Updating item in database."

            completion(nil)
        }
    }
    
    /// Writes an empty `NFCNDEFMessage` to a given `NFCNDEFTag`. The functionality contained in this method appears to be the best way
    /// to delete data from an `NFCNDEFTag`, as Apple doesn't seem to provide a method for doing this.
    /// - Parameters:
    ///   - tag: The tag that is to have its data erased.
    ///   - item: The item that is to be erased from the `tag`.
    ///   - completion: Code to run when this method either successfully deletes the `item`'s data from the `tag` or fails due to an error.
    func writeEmptyNdefMessageToTag(_ tag: NFCNDEFTag, for item: Item, completion: @escaping (NfcError?) -> Void) {
        let emptyNdefMessage = NFCNDEFMessage(
            records: [NFCNDEFPayload(
                format: .empty,
                type: Data(),
                identifier: Data(),
                payload: Data()
            )]
        )

        tag.writeNDEF(emptyNdefMessage) { error in
            guard error == nil else {
                completion(.writeFailed)
                print(error!)
                return
            }

            completion(nil)
        }
    }
    
    /// Checks if a given `NFCNDEFTag` has any `Item`'s data on it.
    /// - Parameters:
    ///   - tag: The tag to be checked.
    ///   - completion: Code to run when this method either successfully evaluates the data on the `tag` or fails due to an error. If this method does not fail,
    ///   `completion` will receive the `Item` found on the tag, along with a `Bool` indicating whether or not the `tag` is empty. If this method does fail,
    ///   `completion` will receive the `Error` that was encountered.
    func checkIfTagIsEmpty(_ tag: NFCNDEFTag, completion: @escaping (Bool?, Item?, Error?) -> Void) {
        tag.readNDEF { ndefMessage, error in
            guard let ndefMessage else {
                completion(true, nil, nil)
                return
            }

            guard error == nil else {
                completion(nil, nil, error)
                return
            }

            if let itemOnTag = try? JSONDecoder().decode(Item.self, from: ndefMessage.records.first!.payload) {
                completion(false, itemOnTag, nil)
                return
            } else {
                completion(true, nil, nil)
                return
            }
        }
    }

    func invalidateSuccessfulSession(invalidate session: NFCNDEFReaderSession?, withAlertMessage alertMessage: String, and action: NfcAction) {
        session?.invalidate()
        session?.alertMessage = alertMessage

        postNfcScanningFinishedNotification(withAction: action)
    }

    /// Handles a given error by displaying an accurage `alertMessage` for the active `nfcSession` and then invalidating
    /// the active `nfcSession`.  Also calls `postNfcScanningFinishedNotification` to notify view controllers
    /// that the session has finished.
    /// - Parameter error: The error that is to be handled.
    func handleError(_ error: NfcError) {
        nfcSession?.invalidate(errorMessage: error.localizedDescription)

        postNfcScanningFinishedNotification(withAction: nil)
    }
    
    /// Posts the `nfcSessionFinished` notification with a given `NfcAction` to notify views that the `nfcSession` has concluded.
    /// - Parameter action: The action to post in the `nfcSessionFinished` notification's `userInfo`.
    func postNfcScanningFinishedNotification(withAction action: NfcAction?) {
        if let action {
            NotificationCenter.default.post(
                name: .nfcSessionFinished,
                object: nil,
                userInfo: [Constants.nfcAction: action]
            )
        } else {
            NotificationCenter.default.post(
                name: .nfcSessionFinished,
                object: nil
            )
        }
    }

    // TODO: Do something here
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print(error)
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { }
}
