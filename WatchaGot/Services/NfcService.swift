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
    var action: NfcAction?

    func startScanning(withAction action: NfcAction) throws {
        guard NFCNDEFReaderSession.readingAvailable else {
            throw NfcError.scanningNotSupported
        }

        self.action = action

        nfcSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        nfcSession?.alertMessage = "Hold your phone near an empty NFC tag."
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
        guard let itemJson = try? JSONEncoder().encode(item) else {
            handleError(NfcError.jsonEncodingFailed)
            return
        }

        let ndefPayload = NFCNDEFPayload(format: .unknown, type: Data(), identifier: Data(), payload: itemJson)
        let ndefMessage = NFCNDEFMessage(records: [ndefPayload])

        tag.writeNDEF(ndefMessage) { [weak self] error in
            if error == nil {
                self?.nfcSession?.alertMessage = "This item's data has been successfully written to your NFC tag."
            } else {
                self?.nfcSession?.alertMessage = NfcError.writeFailed.localizedDescription
                print(error!)
            }

            self?.nfcSession?.invalidate()
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
                print(item)
            } else {
                print(ndefMessage.records)
                self?.nfcSession?.alertMessage = NfcError.jsonDecodingFailed.localizedDescription
            }

            self?.nfcSession?.invalidate()
        }
    }

    func handleError(_ error: NfcError) {
        nfcSession?.alertMessage = error.localizedDescription
        nfcSession?.invalidate()
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("ERROR WHEN INVALIDATING: \(error)")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) { }

    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) { }
}
