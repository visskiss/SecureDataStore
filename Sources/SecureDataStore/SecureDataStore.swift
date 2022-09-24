
import Foundation

public class SecureDataStore {
    
    let sel: Data
    let infoFileSuffix:String
    let documentDirectory:URL
    let keep:Int
    
    public convenience init (salt:String, keep:Int) {
        self.init(salt:salt, keep:keep, documentDirectory:SecureDataStore.defaultDocumentDirectory, infoFileSuffix:"_info")
    }
    public init (salt:String, keep:Int, documentDirectory:URL, infoFileSuffix:String = "_info") {
        self.documentDirectory = documentDirectory
        self.sel = salt.data(using: String.Encoding.utf8)!
        self.infoFileSuffix = infoFileSuffix
        self.keep = keep
    }
    
    
    public func storeData(identifier:String, data:Data) {
        let fullName = identifier + "\(Date().timeIntervalSinceReferenceDate)"
        let fileUrl = url(for:fullName)
        _ = try? data.write(to: fileUrl, options: [.atomic])
        storeFileInfo(for:fileUrl, data:data)
    }
    
   
    public func readLatestFile(named fileName:String) throws -> Data {
        
        var returnData:Data?
        repeat {
            guard let newestVersionURL = newestVersion(of:fileName) else {
                throw SecureDataStoreError.noMatchingFiles
            }
            do {
                returnData = try readDataFrom(newestVersionURL)
            } catch {
                //some issue.  Delete this one and the info file.
                do {
                    try FileManager.default.removeItem(at: newestVersionURL)
                    let urlForInfoFile = infoFileURL(for:newestVersionURL)
                    if FileManager.default.fileExists(atPath: urlForInfoFile.path) {
                        do {
                            try FileManager.default.removeItem(at: urlForInfoFile)
                        } catch {
                            print("Can't delete file info for \(urlForInfoFile.path)")
                        }
                    }
                } catch {
                    //non-removable, now what?????
                    throw SecureDataStoreError.cantDeleteCorruptFile
                }
            }
        } while returnData == nil
        DispatchQueue.main.async(group: nil, qos: .utility, flags: []) {
            self.removeOldest(for:fileName, keep:self.keep)
        }
        return returnData!
    }
    
    public func removeOldest(for identifier:String, keep:Int) {
        let enumerator = FileManager.default.enumerator(at: documentDirectory, includingPropertiesForKeys: [.creationDateKey, .isRegularFileKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles], errorHandler: nil)!
        //Get all the urls and creation dates
        var urls  = [(Date,URL)]()
        for case let url as URL in enumerator {
            if let resourceValues = try? url.resourceValues(forKeys: [.creationDateKey, .isRegularFileKey]) {
                if resourceValues.isRegularFile! {
                    let fileName = url.lastPathComponent
                    if fileName.hasPrefix(identifier) && !fileName.hasSuffix(infoFileSuffix) {
                        urls.append((resourceValues.creationDate!,url))
                    }
                
                }
            }
        }
        //sort dates oldest last
        urls.sort {
            $0.0 > $1.0
        }
        if urls.count > keep {
            let numberToRemove = urls.count - keep
            urls.removeLast(numberToRemove)
        }
        for urlToRemove in urls {
            print(urlToRemove.1.path)
            do {
                try FileManager.default.removeItem(at: urlToRemove.1)
                let fileInfoUrl = infoFileURL(for: urlToRemove.1)
                if FileManager.default.fileExists(atPath: fileInfoUrl.path) {
                    do {
                        try FileManager.default.removeItem(at: fileInfoUrl)
                    } catch {
                        print("Can't delete file info for \(fileInfoUrl.path)")
                    }
                }
            } catch {
                //non-removable, now what?????
                print("Can't delete oldest file named \(urlToRemove.1.path)")
            }

        }
    }
    
    
    private func newestVersion (of identifier:String) -> URL? {
        var latestDate:Date = Date(timeIntervalSinceReferenceDate: 0)
        var latestURL:URL?
        let enumerator = FileManager.default.enumerator(at: documentDirectory, includingPropertiesForKeys: [.creationDateKey, .isRegularFileKey], options: [.skipsSubdirectoryDescendants, .skipsPackageDescendants, .skipsHiddenFiles], errorHandler: nil)!
        for case let url as URL in enumerator{
            if let resourceValues = try? url.resourceValues(forKeys: [.creationDateKey, .isRegularFileKey]) {
                if resourceValues.isRegularFile! {
                    let fileName = url.lastPathComponent
                    if fileName.hasPrefix(identifier) && !fileName.hasSuffix(infoFileSuffix) && (latestURL == nil || latestDate < resourceValues.creationDate!){
                        latestURL = url
                        latestDate = resourceValues.creationDate!
                    }
                }
            }
        }
        return latestURL
    }
    
    private func storeFileInfo (for url: URL, data:Data) {
        var mutableData = data
        mutableData.append(sel)
        let id = mutableData.HSHA(key: sel)
        _ = try? id.write(to: infoFileURL(for:url), options: [.atomic])
    }
    
    private func infoFileURL (for url:URL) -> URL {
        let fileName =  url.lastPathComponent
        return url.deletingLastPathComponent().appendingPathComponent(fileName + infoFileSuffix)
    }
   private static let defaultDocumentDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "conversant.non" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for:.documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    
    private func url(for fileName:String) -> URL {
        return documentDirectory.appendingPathComponent(fileName)
    }

    
    private func readDataFrom(_ url:URL) throws -> Data {
        guard let data = try? Data(contentsOf: url) else {
            NSLog("Read failed for \(url.path)")
            throw SecureDataStoreError.originalFileDoesNotExist
        }
        guard let id = try? Data(contentsOf: infoFileURL(for: url)) else {
            NSLog("Info Read failed for \(infoFileURL(for: url).path)")
            throw SecureDataStoreError.dictionaryReadFailed
        }
        var check_data = NSData(data:data) as Data
        check_data.append(sel)
        let check_id = check_data.HSHA(key:sel)
        guard check_id == id else {
            NSLog("Hash failed for \(url.path)")
            throw SecureDataStoreError.hashMismatch
        }
        return data
    }

}
