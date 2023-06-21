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

    var nfcSession: NFCNDEFReaderSession?
    /// The action that will be performed by `nfcSession`.
    var action: NfcAction?
    
    /// The first alert message shown when the `nfcSession` is displayed.
    var firstNfcSessionAlertMessage: String {
        switch action {
        case .read(_):
            return "Hold your phone near an NFC tag."
        case .write(_):
            return "Hold your phone near an empty NFC tag"
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
        session.connect(to: tag) { [weak self] error in
            guard error == nil else {
                self?.handleError(.connectionFailed)
                return
            }

            tag.queryNDEFStatus { ndefStatus, capacity, error in
                guard error == nil else {
                    self?.handleError(.statusQueryFailed)
                    return
                }

                switch (ndefStatus, self?.action) {
                case (.notSupported, _):
                    self?.handleError(.unsupportedTag)
                case (.readWrite, .read(let item)):
                    self?.read(item, from: tag)
                case (.readWrite, .write(let item)):
                    self?.write(item, to: tag)
                case (.readOnly, _):
                    self?.handleError(.tagIsReadOnly)
                default:
                    self?.handleError(.unknownNdefStatus)
                }
            }
        }
    }

    func write(_ item: Item, to tag: NFCNDEFTag) {
        var updatedItem = item
        updatedItem.addTag()

        guard let itemJson = try? JSONEncoder().encode(updatedItem) else {
            handleError(NfcError.jsonEncodingFailed)
            return
        }

        let ndefPayload = NFCNDEFPayload(format: .unknown, type: Data(), identifier: Data(), payload: itemJson)
        let ndefMessage = NFCNDEFMessage(records: [ndefPayload])

        tag.writeNDEF(ndefMessage) { [weak self] error in
            guard error == nil else {
                self?.handleError(.writeFailed)
                print(error!)
                return
            }

            self?.nfcSession?.alertMessage = "This item's data has been successfully written to your NFC tag. Updating item in database."

            self?.saveTagStatusForItemToDatabase(updatedItem) { error in
                guard error == nil else {
                    self?.handleError(.databaseUpdateFailed)
                    print(error!)
                    return
                }

                self?.nfcSession?.alertMessage = "Database update successful."
                self?.nfcSession?.invalidate()

                self?.postNfcScanningFinishedNotification(for: updatedItem)
            }
        }
    }

    func read(_ item: Item, from tag: NFCNDEFTag) {
        // TODO: Make sure passed in item matches the item read from the tag

        tag.readNDEF { [weak self] ndefMessage, error in
            guard let ndefMessage,
                  !ndefMessage.records.isEmpty else {
                self?.handleError(.tagIsEmpty)
                return
            }

            guard error == nil else {
                self?.handleError(.readFailed)
                print(error!)
                return
            }

            if let item = try? JSONDecoder().decode(Item.self, from: ndefMessage.records.first!.payload) {
                self?.nfcSession?.alertMessage = "Your NFC tag was read successfully!"
                print(item)
            } else {
                print(ndefMessage.records)
                self?.nfcSession?.alertMessage = NfcError.jsonDecodingFailed.localizedDescription
            }

            self?.nfcSession?.invalidate()
            self?.postNfcScanningFinishedNotification(for: nil)
        }
    }
    
    /// Sets the `hasTag` property for a given `Item` to `true` and updates that item in the database.
    /// - Parameters:
    ///   - item: The `Item` that is to be updated.
    ///   - completion: Code to run after the `Item` is successfully updated in the database.
    func saveTagStatusForItemToDatabase(_ item: Item, completion: @escaping (Error?) -> Void) {
        DatabaseService.shared.updateData(update: item, at: Constants.apiItemsUrl) { _, error in
            guard error == nil else {
                completion(error)
                return
            }

            completion(nil)
        }
    }
    
    /// Handles a given error by displaying an accurage `alertMessage` for the active `nfcSession` and then invalidating
    /// the active `nfcSession`.  Also calls `postNfcScanningFinishedNotification` to notify view controllers
    /// that the session has finished.
    /// - Parameter error: The error that is to be handled.
    func handleError(_ error: NfcError) {
        nfcSession?.alertMessage = error.localizedDescription
        nfcSession?.invalidate()
        postNfcScanningFinishedNotification(for: nil)
    }

    
    /// Posts the `nfcSessionFinished` notification to notify views that the `nfcSession` has concluded.
    /// - Parameter item: The `Item` to be sent to the view receiving the notification.
    func postNfcScanningFinishedNotification(for item: Item?) {
        if let item {
            NotificationCenter.default.post(
                name: .nfcSessionFinished,
                object: nil,
                userInfo: [Constants.item: item]
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
        print("ERROR WHEN INVALIDATING: \(error)")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) { }
}
