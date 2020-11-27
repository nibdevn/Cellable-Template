import Foundation

extension String {
    func appendPath(_ value: String) -> String { return self + "/" + value }
}

let fm: FileManager = FileManager.default
let XCODE_FILE_TEMPLATES_PATH = "Xcode.app/Contents/Developer/Library/Xcode/Templates/File Templates"
let DEFAULT_TEMPLATE_CATEGORY_PATH = "Source"
let TEMPLATE_NAME_PATH = "Cellable.xctemplate"
let TEMPLATE_NAME_URL = URL(fileURLWithPath: TEMPLATE_NAME_PATH)

var xcodeContentDirectory: String {
    let urls = fm.urls(for: .applicationDirectory, in: .localDomainMask)
    return urls.count > 0 ? urls[0].absoluteString.replacingOccurrences(of: "file://", with: "").appendPath(XCODE_FILE_TEMPLATES_PATH) : XCODE_FILE_TEMPLATES_PATH
}

func processing() {
    guard checkTemplatePath() else {
        printInConsole("❌ Can't find \(TEMPLATE_NAME_PATH) Folder")
        return
    }
    guard checkXcodePath() else {
        printInConsole("❌ Can't find Xcode File Template Folder")
        return
    }
    let path = permissionCustomTemplateCategory()
    process(path)
}

func checkTemplatePath() -> Bool {
    return fm.fileExists(atPath: TEMPLATE_NAME_PATH)
}

func checkXcodePath() -> Bool {
    return fm.fileExists(atPath: xcodeContentDirectory)
}

func permissionCustomTemplateCategory() -> String {
    if let answer = input("Would you like to install \"\(TEMPLATE_NAME_PATH)\" with custom category?\n(If you answer no it will be install in source category) [Yes / No]") {
        if answer.lowercased() == "yes" || answer.lowercased() == "y" {
            if let category = input("Template Category Name:") {
                return xcodeContentDirectory.appendPath(category)
            }
        }
    }
    return xcodeContentDirectory.appendPath(DEFAULT_TEMPLATE_CATEGORY_PATH)
}

func process(_ basePath: String) {
    do {
        let baseURL = URL(fileURLWithPath: basePath)
        let directoryPath = basePath.appendPath(TEMPLATE_NAME_PATH)
        let directoryURL = URL(fileURLWithPath: directoryPath)
        
        if fm.fileExists(atPath: basePath) == false { try fm.createDirectory(at: baseURL, withIntermediateDirectories: true, attributes: nil) }
        if fm.fileExists(atPath: directoryPath) {
            try fm.removeItem(at: directoryURL)
            try fm.copyItem(at: TEMPLATE_NAME_URL, to: directoryURL)
            printInConsole("✅  Template already exists.\nSo has been replaced successfully.")
        } else {
            try fm.copyItem(at: TEMPLATE_NAME_URL, to: directoryURL)
            printInConsole("✅  Template installed successfully.")
        }
    }catch let error as NSError {
        if let reason = error.localizedFailureReason {
            printInConsole("❌  Ooops! Something went wrong: \(reason)")
        }else {
            printInConsole("❌  Ooops! Something went wrong")
        }
    }
}

func input(_ prefix: String? = nil) -> String? {
    if let pf = prefix, pf.isEmpty == false { print(pf, terminator:" ") }
    return readLine()
}

func printInConsole(_ message:Any){
    print("====================================")
    print("\(message)")
    print("====================================")
}

processing()
