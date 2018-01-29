//
//  Options.swift
//  MaximoRESTSDK
//
//  Created by Silvino Vieira de Vasconcelos Neto on 11/01/2018.
//  Copyright © 2018 IBM. All rights reserved.
//

import Foundation

/**
 *
 * {@code Options} is served for {@code MaximoConnector}.
 *
 * <p>
 * The following code shows how to initial {@code MaximoConnector} using {@code MaximoConnector} and {@code Options}Constructor</p>
 * <pre>
 * <code>
 * var mc : MaximoConnector = MaximoConnector(options: Options().user(user: userName)
 *  .password(password: password).mt(mtMode: true).lean(lean: false).auth(authMode: authMethod)
 *  .host(host: hostAddress).port(port: portNum))
 * </code>
 * </pre>
 */
public class Options {

    let AUTH_BASIC = "basic"
    let AUTH_MAXAUTH = "maxauth"
    let AUTH_FORM = "form"

    var host: String?
    var port: Int?
    var authMode: String?
    var user: String?
    var password: String?
    var ssl: Bool = false
    var mt: Bool = false
    var lean: Bool = false
    var publicURI: String?
    var appContext: String = "maximo"
    var apiContext: String = "oslc"
    var appURI: String?
    var tenantcode: String = "00"
    
    public init() {
    }

    public func host(host: String) -> Options
    {
        self.host = host
        return self
    }

    public func maxrest() -> Options
    {
        appContext = "maxrest"
        return self
    }

    public func appContext(context: String) -> Options
    {
        appContext = context
        return self
    }
    
    public func apiContext(apiContext: String) -> Options
    {
        self.apiContext = apiContext
        return self
    }
    
    public func https() -> Options
    {
        self.ssl = true
        return self
    }
    
    public func http() -> Options
    {
        self.ssl = false
        return self
    }
    
    public func port(port: Int) -> Options
    {
        self.port = port
        return self
    }
    
    public func auth(authMode: String) -> Options
    {
        self.authMode = authMode
        return self
    }
    
    public func mt(mtMode: Bool) -> Options
    {
        self.mt = mtMode
        return self
    }
    
    public func user(user: String) -> Options
    {
        self.user = user
        return self
    }
    
    public func password(password: String) -> Options
    {
        self.password = password
        return self
    }
    
    public func AppURI(appURI: String) -> Options
    {
        self.appURI = appURI
        return self
    }
    
    public func lean(lean: Bool) -> Options
    {
        self.lean = lean
        return self
    }
    
    public func tenantCode(tenantCode: String) -> Options
    {
        self.tenantcode = tenantCode
        return self
    }
    
    public func getPassword() -> String?
    {
        return self.password
    }
    
    public func getUser() -> String?
    {
        return self.user
    }
    
    public func isBasicAuth() -> Bool
    {
        return self.authMode == AUTH_BASIC
    }
    
    public func isFormAuth() -> Bool
    {
        return self.authMode == AUTH_FORM
    }
    
    public func isMaxAuth() -> Bool
    {
        return self.authMode == AUTH_MAXAUTH
    }
    
    public func isMultiTenancy() -> Bool
    {
        return self.mt
    }
    
    public func isLean() -> Bool
    {
        return self.lean
    }
    
    public func getHost() -> String
    {
        return self.host!
    }
    
    public func getPort() -> Int
    {
        if self.port == nil {
            self.port = -1
        }
        return self.port!
    }
    
    public func getTenantCode() -> String
    {
        return self.tenantcode
    }

    //Get app URI
    public func getAppURI() -> String
    {
        if appURI != nil {
            if mt == true && appURI!.contains("tenantcode") == false {
                appURI! += (appURI!.contains("?") ? "" : "?")
                appURI! += "&_tenantcode=" + tenantcode
            }

            if self.isLean() {
                if self.appURI!.contains("&lean=0") {
                    self.appURI = self.appURI!.replacingOccurrences(of: "&lean=0", with: "&lean=1")
                } else if self.appURI!.contains("&lean=1") == false {
                    appURI! += (appURI!.contains("?") ? "" : "?")
                    appURI! += "&lean=1"
                }
                return self.appURI!
            }
            else {
                if self.appURI!.contains("&lean=1") {
                    self.appURI = self.appURI!.replacingOccurrences(of: "&lean=1", with: "&lean=0")
                } else if self.appURI!.contains("&lean=0") == false {
                    appURI! += (appURI!.contains("?") ? "" : "?")
                    appURI! += "&lean=0"
                }
                return self.appURI!
            }
        }

        var strb = ssl ? "https://" : "http://"
        strb.append(host!)
        if self.port != nil {
            strb.append(":" + String(port!))
        }

        strb.append("/" + appContext)
        strb.append("/" + self.apiContext)
        if mt == true {
            strb.append(strb.contains("?") ? "" : "?")
            strb.append("&_tenantcode=" + tenantcode)
        }

        if lean == true {
            strb.append(strb.contains("?") ? "" : "?")
            strb.append("&lean=1")
        }
        self.appURI = strb
        return self.appURI!
    }

    //Get public URI
    public func getPublicURI() -> String
    {
        if publicURI != nil {
            return self.publicURI!
        }
        else if appURI != nil {
            var strs = appURI!.split(separator: "/")
            strs = strs[1].split(separator: ":")
            self.host = String(strs[0]);
            if strs.count > 1 {
                self.port = Int(String(strs[1]))
            }
        }

        var strb = ssl ? "https://" : "http://"
        strb.append(host!);
        if self.port != nil {
            strb.append(":" + String(port!))
        }

        strb.append("/" + appContext)
        strb.append("/" + self.apiContext)
        self.publicURI = strb
        return self.publicURI!;
    }
}
