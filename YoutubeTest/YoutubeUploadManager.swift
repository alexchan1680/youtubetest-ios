//
//  YoutubeUploadManager.swift
//  YoutubeTest
//
//  Created by Alex on 11/3/2016.
//

import Foundation
import MobileCoreServices

class YoutubeUploadManager{
    private let service:GTLServiceYouTube
    
    enum Error:ErrorType{
        case NoUploadFile
    }
    
    enum VideoResource{
        case URL(NSURL)
        case Raw(NSData)
        
        private var uploadParameters:GTLUploadParameters {
            switch self {
            case .URL(let url):
                return GTLUploadParameters(fileURL: url, MIMEType: MIMEType)
            case .Raw(let data):
                return GTLUploadParameters(data: data, MIMEType: MIMEType)
            }
        }
        
        var MIMEType:String{
            switch self {
            case .URL(let url):
                guard let fileName = url.lastPathComponent else {
                    return "video/*"
                }
                return MIMETypeForFilename(fileName, defaultMIMEType: "video/*")
            default:
                return "video/*"
            }
        }
        
        var available:Bool{
            switch self {
            case .URL(let url):
                return url.checkPromisedItemIsReachableAndReturnError(nil)
            default:
                return true
            }
        }
        
        private func MIMETypeForFilename(fileName:String, defaultMIMEType:String) -> String{
            let ext = (fileName as NSString).pathExtension
            guard let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, ext, nil)
                , let copied = UTTypeCopyPreferredTagWithClass(uti.takeUnretainedValue(), kUTTagClassMIMEType)
                else {
                    return defaultMIMEType
            }
            return copied.takeUnretainedValue() as String
        }
    }
    
    // Initialize Upload Manager
    init (service:GTLServiceYouTube){
        precondition(service.authorizer?.canAuthorize ?? false, "A valid youtube service should be provided.")
        self.service = service
    }
    
    /**
     Upload Resource
     - Parameter resource : VideoResource
     - Parameter title : Video Title
     - Parameter description : Viddeo Description
     - Parameter tags : Video Tags
     - Parameter completionHandler: GTLServiceCompletionHandler
     - Parameter progress : GTLServiceUploadProgressBlock
     - Parameter uploadLocationURL : The url to be used for saving upload status (for resuming or restarting upload.) So uploading information will be written at "uploadLocationURL"
    */
    func uploadResource(resource:VideoResource, title:String, description:String, tags:[String] = [], completionHandler:GTLServiceCompletionHandler, progress:GTLServiceUploadProgressBlock? = nil, uploadLocationURL:NSURL?) throws -> GTLServiceTicket {
        
        guard resource.available else {
            throw Error.NoUploadFile
        }
        
        // Create Video Status
        let status = GTLYouTubeVideoStatus().then{
            $0.privacyStatus = "public"
        }
        
        // Create snippet
        let snippet = GTLYouTubeVideoSnippet().then{
            $0.title = title
            $0.descriptionProperty = description
            $0.tags = tags
        }
        
        let video = GTLYouTubeVideo().then{
            $0.snippet = snippet
            $0.status = status
        }
        
        let parameters = resource.uploadParameters.then{
            $0.uploadLocationURL = uploadLocationURL
        }
        
        let query = GTLQueryYouTube.queryForVideosInsertWithObject(video, part: "snippet, status", uploadParameters:parameters)
        
        let ticket = service.executeQuery(query, completionHandler: completionHandler).then{
            $0.uploadProgressBlock = progress
        }
        return ticket
    }
    
    /**
     Resume upload video.
    */
    func resumeUploadResource(resource:VideoResource, uploadLocationURL:NSURL, completionHandler:GTLServiceCompletionHandler, progress:GTLServiceUploadProgressBlock? = nil) throws -> GTLServiceTicket{
        guard resource.available else {
            throw Error.NoUploadFile
        }
        
        let video = GTLYouTubeVideo()
        let parameters = resource.uploadParameters.then{
            $0.uploadLocationURL = uploadLocationURL
        }
        
        let query = GTLQueryYouTube.queryForVideosInsertWithObject(video, part: "snippet, status", uploadParameters:parameters)
        
        let ticket = service.executeQuery(query, completionHandler: completionHandler).then{
            $0.uploadProgressBlock = progress
        }
        return ticket
    }
}