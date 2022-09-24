//
//  FileHelper.swift
//  Super Speed Solitaire
//
//  Created by Daniel Kanaan on 2/18/15.
//  Copyright (c) 2015 Daniel Kanaan. All rights reserved.
//

import Foundation

public enum SecureDataStoreError: Error {
    case originalFileDoesNotExist
    case helperFileDoesNotExist
    case hashEntryNotFound
    case dictionaryReadFailed
    case hashMismatch
    case failedCast
    case noMatchingFiles
    case cantDeleteCorruptFile
}

