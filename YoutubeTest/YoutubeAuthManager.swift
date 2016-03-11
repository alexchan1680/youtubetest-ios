//
//  YoutubeAuthManager.swift
//  YoutubeTest
//
//  Created by Alex on 11/3/2016.
//

import Foundation

class YoutubeAuthManager {
    let clientID:String
    let authKeyChainName:String
    
    /**
     Creates Youtube service authentication manager
     You can get clientID from Google Develoepr Console by creating new Credential for iOS App.
     - Parameter clientID: ClientID for this App.
     - Parameter authKeyChainName : KeyChainItemName to be used for storing authentication.
    */
    init (clientID:String, authKeyChainName:String){
        self.clientID = clientID
        self.authKeyChainName = authKeyChainName
    }
    
    
    /// Loads authentication from keychain.
    private var authorizer:GTMOAuth2Authentication {
        return GTMOAuth2ViewControllerTouch.authForGoogleFromKeychainForName(authKeyChainName, clientID: clientID, clientSecret: nil)
    }
    
    /// Check if already authroized.
    var authorized:Bool {
        return authorizer.canAuthorize
    }
    
    /**
     Tries to load auth token from Key Chain and creates service.
     It will create new instance each time (not shared instance) when token is stored in keychain item.
     Use this property in correct use case.
    */
    var authorizedService:GTLServiceYouTube?{
        let authorizer = self.authorizer
        guard authorizer.canAuthorize else {
            return nil
        }
        let service = GTLServiceYouTube()
        service.authorizer = authorizer
        return service
    }
    
    /**
     Create an instance of Google OAuth2 ViewController with YoutubeService Scope.
     - Parameter handler : (GTLServiceYouTube?, NSError?) -> Void
     <br>You can access GTMOAuth2Authentication instance by accessing service.authorizer
     - Returns : GTMOAuth2ViewControllerTouch instance.
    */
    func authViewControllerWithCompletionHandler(handler:(GTMOAuth2ViewControllerTouch, GTLServiceYouTube?, NSError?) -> Void) -> GTMOAuth2ViewControllerTouch{
        return GTMOAuth2ViewControllerTouch(
            scope: kGTLAuthScopeYouTube,
            clientID: clientID,
            clientSecret: nil,
            keychainItemName: authKeyChainName,
            completionHandler: { (vc, auth, error) -> Void in
                guard let auth = auth where error == nil else {
                    handler(vc, nil, error)
                    return
                }
                let service = GTLServiceYouTube()
                service.authorizer = auth
                handler(vc, service, nil)
        })
    }
    
    /**
     Do log out.
    */
    func removeAuthorizedToken(){
        GTMOAuth2ViewControllerTouch.removeAuthFromKeychainForName(authKeyChainName)
    }
    
    /**
     Do log out.
    */
    func logOut(){
        removeAuthorizedToken()
    }
}