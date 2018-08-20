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
    
    /// Fuction to set the host address as an option.
    ///
    /// - Parameter host: IP or DNS address of Maximo's service
    /// - Returns: Options object wihtin a new host information set.
    public func host(host: String) -> Options
    {
        self.host = host
        return self
    }

    
    /// Fuction to set Maximo rest service id. (it is hardcoded to 'maxrest')
    ///
    /// - Returns: Options object with appContext param set to maxrest.
    public func maxrest() -> Options
    {
        appContext = "maxrest"
        return self
    }

    ///  Function to set application context.
    ///
    /// - Parameter context: context of this application (i.e. maximo)
    /// - Returns: Options object within a new appContext value set.
    public func appContext(context: String) -> Options
    {
        appContext = context
        return self
    }
    
    /// Context operation for this API.
    ///
    /// - Parameter apiContext: api context (i.e. oslc)
    /// - Returns: Options object within the apiContext param set.
    public func apiContext(apiContext: String) -> Options
    {
        self.apiContext = apiContext
        return self
    }
    
    /// Enables secure HTTP.
    ///
    /// - Returns: Options object set with ssl param set to <b>TURE</b>.
    public func https() -> Options
    {
        self.ssl = true
        return self
    }
    
    /// Disable secure HTTP.
    ///
    /// - Returns: Options object wihtin the ssl parata set to <b>FALSE</b>
    public func http() -> Options
    {
        self.ssl = false
        return self
    }
    
    /// Define the service port
    ///
    /// - Parameter port: service destination port
    /// - Returns: Options object within the port param set.
    public func port(port: Int) -> Options
    {
        self.port = port
        return self
    }
    
    /// Define the authentication mode.
    ///
    /// - Parameter authMode: authentication mode (i.e. maxAuth)
    /// - Returns: Option object with authMode param set.
    public func auth(authMode: String) -> Options
    {
        self.authMode = authMode
        return self
    }
    
    /// Enables/Disable Maximo Tenant mode.
    ///
    /// - Parameter mtMode: TRUE to enable and FALSE to disble.
    /// - Returns: Option object within mt param set.
    public func mt(mtMode: Bool) -> Options
    {
        self.mt = mtMode
        return self
    }
    
    /// Define the user credentials.
    ///
    /// - Parameter user: user name.
    /// - Returns: Options object with user param set.
    public func user(user: String) -> Options
    {
        self.user = user
        return self
    }
    
    /// Define the password credentials.
    ///
    /// - Parameter password: password
    /// - Returns: Options object with password param set.
    public func password(password: String) -> Options
    {
        self.password = password
        return self
    }
    
    /// Determine the app URI
    ///
    /// - Parameter appURI: URI of application
    /// - Returns: Options object with the appURI param set.
    public func AppURI(appURI: String) -> Options
    {
        self.appURI = appURI
        return self
    }
    
    /// Enables lean
    ///
    /// - Parameter lean: TRUE to enable and FALSE to disble.
    /// - Returns: Options object with the lean param set.
    public func lean(lean: Bool) -> Options
    {
        self.lean = lean
        return self
    }
    
    /// Set the tenant code.
    ///
    /// - Parameter tenantCode: tenant code
    /// - Returns: Options object with the tenantCode param set.
    public func tenantCode(tenantCode: String) -> Options
    {
        self.tenantcode = tenantCode
        return self
    }
    
    /// Returns the passaword
    ///
    /// - Returns: String with the passworld
    public func getPassword() -> String?
    {
        return self.password
    }
    
    /// Returns the user name
    ///
    /// - Returns: String with user name
    public func getUser() -> String?
    {
        return self.user
    }
    
    /// Check if this app is using the basic authentication
    ///
    /// - Returns: boolean value <b>TRUE</b> for yes, <b>FALSE</b> to no
    public func isBasicAuth() -> Bool
    {
        return self.authMode == AUTH_BASIC
    }
    
    /// Returns if this app is using a form authentication
    ///
    /// - Returns: boolean value <b>TRUE</b> for yes, <b>FALSE</b> to no
    public func isFormAuth() -> Bool
    {
        return self.authMode == AUTH_FORM
    }
    
    /// Returns if this application is using a Maximo Authentication formula.
    ///
    /// - Returns: boolean value <b>TRUE</b> for yes, <b>FALSE</b> to no
    public func isMaxAuth() -> Bool
    {
        return self.authMode == AUTH_MAXAUTH
    }
    
    /// Returns if this app is desgined to attend a MultiTenancy.
    ///
    /// - Returns: boolean value <b>TRUE</b> for yes, <b>FALSE</b> to no
    public func isMultiTenancy() -> Bool
    {
        return self.mt
    }
    
    /// Returns if this application is a Lean application
    ///
    /// - Returns: boolean value <b>TRUE</b> for yes, <b>FALSE</b> to no
    public func isLean() -> Bool
    {
        return self.lean
    }
    
    /// Returns a string conatining the IP/DNS of the application host.
    ///
    /// - Returns: String
    public func getHost() -> String
    {
        return self.host!
    }
    
    /// Returns the logical port where the service was configured to operating
    ///
    /// - Returns: Integer value
    public func getPort() -> Int
    {
        if self.port == nil {
            self.port = -1
        }
        return self.port!
    }
    
    /// Return the Tenant code
    ///
    /// - Returns: String containing Tenant's code.
    public func getTenantCode() -> String
    {
        return self.tenantcode
    }

    /// Get app URI
    ///
    /// - Returns: String URL containing the app location.
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

    /// Get public URI
    ///
    /// - Returns: String containing the public URI
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
