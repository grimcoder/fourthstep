//
//  Created by Anthony Levings on 25/06/2014.

//

import Foundation

import Foundation

//pragma mark - strip slashes
public class FileHelper {
    public static func stripSlashIfNeeded(stringWithPossibleSlash:String) -> String {
        var stringWithoutSlash:String = stringWithPossibleSlash
        // If the file name contains a slash at the beginning then we remove so that we don't end up with two
        if stringWithPossibleSlash.hasPrefix("/") {
            stringWithoutSlash = stringWithPossibleSlash.substringFromIndex(stringWithoutSlash.startIndex.advancedBy(1))
        }
        // Return the string with no slash at the beginning
        return stringWithoutSlash
    }
    
    public static func createSubDirectory(subdirectoryPath:String) -> Bool {
        var error:NSError?
        var isDir:ObjCBool=false;
        let exists:Bool = NSFileManager.defaultManager().fileExistsAtPath(subdirectoryPath, isDirectory:&isDir)
        if (exists) {
            /* a file of the same name exists, we don't care about this so won't do anything */
            if isDir {
                /* subdirectory already exists, don't create it again */
                return true;
            }
        }
        var success:Bool
        do {
            try NSFileManager.defaultManager().createDirectoryAtPath(subdirectoryPath, withIntermediateDirectories:true, attributes:nil)
            success = true
        } catch let error1 as NSError {
            error = error1
            success = false
        }
        
        if (error != nil) { print(error) }
        
        return success;
    }
}

import Foundation

public struct FileDirectory {
    public static func applicationDirectory(directory:NSSearchPathDirectory) -> NSURL? {
        
        var appDirectory:String?
        var paths:[AnyObject] = NSSearchPathForDirectoriesInDomains(directory, NSSearchPathDomainMask.UserDomainMask, true);
        if paths.count > 0 {
            if let pathString = paths[0] as? String {
                appDirectory = pathString
            }
        }
        if let dD = appDirectory {
            return NSURL(string:dD)
        }
        return nil
    }
    
    
    public static func applicationTemporaryDirectory() -> NSURL? {
        return NSURL(string: NSTemporaryDirectory())
        
    }
}




import Foundation
// see here for Apple's ObjC Code https://developer.apple.com/library/mac/documentation/FileManagement/Conceptual/FileSystemProgrammingGuide/AccessingFilesandDirectories/AccessingFilesandDirectories.html
public class FileList {
    public static func allFilesAndFolders(inDirectory directory:NSSearchPathDirectory, subdirectory:String?) -> [NSURL]? {
        
        // Create load path
        if let loadPath = buildPathToDirectory(directory, subdirectory: subdirectory) {
            
            let url = NSURL(fileURLWithPath: loadPath)
            var array:[NSURL]? = nil
            
            let properties = [NSURLLocalizedNameKey,
                NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey]
            
            do {
                array = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: properties, options:NSDirectoryEnumerationOptions.SkipsHiddenFiles)
                
            } catch let error1 as NSError {
                print(error1.description)
            }
            return array
        }
        return nil
    }
    
    public static func allFilesAndFoldersInTemporaryDirectory(subdirectory:String?) -> [NSURL]? {
        
        // Create load path
        let loadPath = buildPathToTemporaryDirectory(subdirectory)
        
        let url = NSURL(fileURLWithPath: loadPath)
        var array:[NSURL]? = nil
        
        let properties = [NSURLLocalizedNameKey,
            NSURLCreationDateKey, NSURLLocalizedTypeDescriptionKey]
        do {
            array = try NSFileManager.defaultManager().contentsOfDirectoryAtURL(url, includingPropertiesForKeys: properties, options:NSDirectoryEnumerationOptions.SkipsHiddenFiles) as [NSURL] }
        catch let error1 as NSError {
            print(error1.description)
        }
        return array
        
        
    }
    
    
    // private methods
    
    private static func buildPathToDirectory(directory:NSSearchPathDirectory, subdirectory:String?) -> String?  {
        // Remove unnecessary slash if need
        // Remove unnecessary slash if need
        var subDir = ""
        if let sub = subdirectory {
            subDir = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file delete path
        var buildPath = ""
        
        if let direct = FileDirectory.applicationDirectory(directory),
            path = direct.path {
                buildPath = path + "/"
        }
        
        
        buildPath += subDir
        buildPath += "/"
        
        
        var dir:ObjCBool = true
        let dirExists = NSFileManager.defaultManager().fileExistsAtPath(buildPath, isDirectory:&dir)
        if dir.boolValue == false {
            return nil
        }
        if dirExists == false {
            return nil
        }
        return buildPath
    }
    public static func buildPathToTemporaryDirectory(subdirectory:String?) -> String {
        // Remove unnecessary slash if need
        
        var subDir:String?
        if let sub = subdirectory {
            subDir = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file load path
        var loadPath = ""
        
        if let direct = FileDirectory.applicationTemporaryDirectory(),
            path = direct.path {
                loadPath = path + "/"
        }
        
        if let sub = subDir {
            loadPath += sub
            loadPath += "/"
        }
        
        
        // Add requested save path
        return loadPath
    }
    
    
    
}


import Foundation

public struct FileLoad {
    
    
    public static func loadData(path:String, directory:NSSearchPathDirectory, subdirectory:String?) -> NSData?
    {
        
        let loadPath = buildPath(path, inDirectory: directory, subdirectory: subdirectory)
        // load the file and see if it was successful
        let data = NSFileManager.defaultManager().contentsAtPath(loadPath)
        // Return data
        return data
        
    }
    
    
    public static func loadDataFromTemporaryDirectory(path:String, subdirectory:String?) -> NSData?
    {
        
        
        let loadPath = buildPathToTemporaryDirectory(path, subdirectory: subdirectory)
        // Save the file and see if it was successful
        let data = NSFileManager.defaultManager().contentsAtPath(loadPath)
        
        // Return status of file save
        return data
        
        
    }
    
    
    // string methods
    
    public static func loadString(path:String, directory:NSSearchPathDirectory, subdirectory:String?, encoding enc:NSStringEncoding = NSUTF8StringEncoding) -> String?
    {
        let loadPath = buildPath(path, inDirectory: directory, subdirectory: subdirectory)
        
        var error:NSError?
        print(loadPath)
        // Save the file and see if it was successful
        let text:String?
        do {
            text = try String(contentsOfFile:loadPath, encoding:enc)
        } catch let error1 as NSError {
            error = error1
            text = nil
        }
        
        
        return text
        
    }
    
    
    public static func loadStringFromTemporaryDirectory(path:String, subdirectory:String?, encoding enc:NSStringEncoding = NSUTF8StringEncoding) -> String? {
        
        let loadPath = buildPathToTemporaryDirectory(path, subdirectory: subdirectory)
        
        var error:NSError?
        print(loadPath)
        // Save the file and see if it was successful
        var text:String?
        do {
            text = try String(contentsOfFile:loadPath, encoding:enc)
        } catch let error1 as NSError {
            error = error1
            text = nil
        }
        
        
        return text
        
    }
    
    
    
    // private methods
    
    private static func buildPath(path:String, inDirectory directory:NSSearchPathDirectory, subdirectory:String?) -> String  {
        // Remove unnecessary slash if need
        let newPath = FileHelper.stripSlashIfNeeded(path)
        var subDir:String?
        if let sub = subdirectory {
            subDir = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file load path
        var loadPath = ""
        
        if let direct = FileDirectory.applicationDirectory(directory),
            path = direct.path {
                loadPath = path + "/"
        }
        
        if let sub = subDir {
            loadPath += sub
            loadPath += "/"
        }
        
        
        // Add requested load path
        loadPath += newPath
        return loadPath
    }
    public static func buildPathToTemporaryDirectory(path:String, subdirectory:String?) -> String {
        // Remove unnecessary slash if need
        let newPath = FileHelper.stripSlashIfNeeded(path)
        var subDir:String?
        if let sub = subdirectory {
            subDir = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file load path
        var loadPath = ""
        
        if let direct = FileDirectory.applicationTemporaryDirectory(),
            path = direct.path {
                loadPath = path + "/"
        }
        
        if let sub = subDir {
            loadPath += sub
            loadPath += "/"
        }
        
        
        // Add requested save path
        loadPath += newPath
        return loadPath
    }
    
}


import Foundation


public struct FileSave {
    
    
    public static func saveData(fileData:NSData, directory:NSSearchPathDirectory, path:String, subdirectory:String?) -> Bool
    {
        
        let savePath = buildPath(path, inDirectory: directory, subdirectory: subdirectory)
        // Save the file and see if it was successful
        let ok:Bool = NSFileManager.defaultManager().createFileAtPath(savePath,contents:fileData, attributes:nil)
        
        // Return status of file save
        return ok
        
    }
    
    public static func saveDataToTemporaryDirectory(fileData:NSData, path:String, subdirectory:String?) -> Bool
    {
        
        let savePath = buildPathToTemporaryDirectory(path, subdirectory: subdirectory)
        // Save the file and see if it was successful
        let ok:Bool = NSFileManager.defaultManager().createFileAtPath(savePath,contents:fileData, attributes:nil)
        
        // Return status of file save
        return ok
    }
    
    
    // string methods
    
    public static func saveString(fileString:String, directory:NSSearchPathDirectory, path:String, subdirectory:String) -> Bool {
        let savePath = buildPath(path, inDirectory: directory, subdirectory: subdirectory)
        var error:NSError?
        // Save the file and see if it was successful
        let ok:Bool
        do {
            try fileString.writeToFile(savePath, atomically:false, encoding:NSUTF8StringEncoding)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if (error != nil) {print(error)}
        
        // Return status of file save
        return ok
        
    }
    public static func saveStringToTemporaryDirectory(fileString:String, path:String, subdirectory:String) -> Bool {
        
        let savePath = buildPathToTemporaryDirectory(path, subdirectory: subdirectory)
        
        var error:NSError?
        // Save the file and see if it was successful
        var ok:Bool
        do {
            try fileString.writeToFile(savePath, atomically:false, encoding:NSUTF8StringEncoding)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if (error != nil) {
            print(error)
        }
        
        // Return status of file save
        return ok;
        
    }
    
    
    
    
    // private methods
    public static func buildPath(path:String, inDirectory directory:NSSearchPathDirectory, subdirectory:String?) -> String  {
        // Remove unnecessary slash if need
        let newPath = FileHelper.stripSlashIfNeeded(path)
        var newSubdirectory:String?
        if let sub = subdirectory {
            newSubdirectory = FileHelper.stripSlashIfNeeded(sub)
        }
        // Create generic beginning to file save path
        var savePath = ""
        if let direct = FileDirectory.applicationDirectory(directory),
            path = direct.path {
                savePath = path + "/"
        }
        
        if (newSubdirectory != nil) {
            savePath.appendContentsOf(newSubdirectory!)
            FileHelper.createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += newPath
        
        return savePath
    }
    
    public static func buildPathToTemporaryDirectory(path:String, subdirectory:String?) -> String {
        // Remove unnecessary slash if need
        let newPath = FileHelper.stripSlashIfNeeded(path)
        var newSubdirectory:String?
        if let sub = subdirectory {
            newSubdirectory = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file save path
        var savePath = ""
        if let direct = FileDirectory.applicationTemporaryDirectory(),
            path = direct.path {
                savePath = path + "/"
        }
        
        if let sub = newSubdirectory {
            savePath += sub
            FileHelper.createSubDirectory(savePath)
            savePath += "/"
        }
        
        // Add requested save path
        savePath += newPath
        return savePath
    }
    
}


public struct FileDelete {
    
    public static func deleteFile(path:String, directory:NSSearchPathDirectory,  subdirectory:String?) -> Bool
    {
        let deletePath = buildPath(path, inDirectory: directory, subdirectory: subdirectory)
        
        // Delete the file and see if it was successful
        var error:NSError?
        let ok:Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(deletePath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil {
            print(error)
        }
        // Return status of file delete
        return ok;
        
    }
    
    
    public static func deleteFileFromTemporaryDirectory(path:String, subdirectory:String?) -> Bool
    {
        let deletePath = buildPathToTemporaryDirectory(path, subdirectory: subdirectory)
        
        // Delete the file and see if it was successful
        var error:NSError?
        let ok:Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(deletePath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        if error != nil {
            print(error)
        }
        // Return status of file delete
        return ok
    }
    
    
    // Delete folders
    
    public static func deleteSubDirectory(directory:NSSearchPathDirectory, subdirectory:String) -> Bool
    {
        // Remove unnecessary slash if need
        let subDir = FileHelper.stripSlashIfNeeded(subdirectory)
        
        // Create generic beginning to file delete path
        var deletePath = ""
        
        if let direct = FileDirectory.applicationDirectory(directory),
            path = direct.path {
                deletePath = path + "/"
        }
        
        
        deletePath += subDir
        deletePath += "/"
        
        
        var dir:ObjCBool = true
        let dirExists = NSFileManager.defaultManager().fileExistsAtPath(deletePath, isDirectory:&dir)
        if dir.boolValue == false {
            return false
        }
        if dirExists == false {
            return false
        }
        
        
        // Delete the file and see if it was successful
        var error:NSError?
        let ok:Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(deletePath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        
        if error != nil {
            print(error)
        }
        // Return status of file delete
        return ok
        
    }
    
    
    
    
    public static func deleteSubDirectoryFromTemporaryDirectory(subdirectory:String) -> Bool
    {
        // Remove unnecessary slash if need
        let subDir = FileHelper.stripSlashIfNeeded(subdirectory)
        
        // Create generic beginning to file delete path
        var deletePath = ""
        
        if let direct = FileDirectory.applicationTemporaryDirectory(),
            path = direct.path {
                deletePath = path + "/"
        }
        
        
        deletePath += subDir
        deletePath += "/"
        
        
        var dir:ObjCBool = true
        let dirExists = NSFileManager.defaultManager().fileExistsAtPath(deletePath, isDirectory:&dir)
        if dir.boolValue == false {
            return false
        }
        if dirExists == false {
            return false
        }
        
        
        // Delete the file and see if it was successful
        var error:NSError?
        let ok:Bool
        do {
            try NSFileManager.defaultManager().removeItemAtPath(deletePath)
            ok = true
        } catch let error1 as NSError {
            error = error1
            ok = false
        }
        
        
        if error != nil {
            print(error)
        }
        // Return status of file delete
        return ok
        
    }
    
    
    // private methods
    // private methods
    
    private static func buildPath(path:String, inDirectory directory:NSSearchPathDirectory, subdirectory:String?) -> String  {
        // Remove unnecessary slash if need
        let newPath = FileHelper.stripSlashIfNeeded(path)
        var subDir:String?
        if let sub = subdirectory {
            subDir = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file load path
        var loadPath = ""
        
        if let direct = FileDirectory.applicationDirectory(directory),
            path = direct.path {
                loadPath = path + "/"
        }
        
        if let sub = subDir {
            loadPath += sub
            loadPath += "/"
        }
        
        
        // Add requested load path
        loadPath += newPath
        return loadPath
    }
    public static func buildPathToTemporaryDirectory(path:String, subdirectory:String?) -> String {
        // Remove unnecessary slash if need
        let newPath = FileHelper.stripSlashIfNeeded(path)
        var subDir:String?
        if let sub = subdirectory {
            subDir = FileHelper.stripSlashIfNeeded(sub)
        }
        
        // Create generic beginning to file load path
        var loadPath = ""
        
        if let direct = FileDirectory.applicationTemporaryDirectory(),
            path = direct.path {
                loadPath = path + "/"
        }
        
        if let sub = subDir {
            loadPath += sub
            loadPath += "/"
        }
        
        
        // Add requested save path
        loadPath += newPath
        return loadPath
    }
    
    
    
    
    
}