import ballerina/log;

public isolated function info(string msg, error? err = (), log:KeyValues context = {}) {
    if err is error {
        log:printInfo(msg, err, keyValues = context);
    } else {
         log:printInfo(msg, keyValues = context);
    }
}

public isolated function logError(string msg, error? err = (), log:KeyValues context = {}) {
    if err is error {
        log:printError(msg, err, keyValues = context);
    } else {
        log:printError(msg, keyValues = context);
    }
}

public isolated function debug(string msg, error? err = (), log:KeyValues context = {}) {
     if err is error {
        log:printDebug(msg, err, keyValues = context);
    } else {
        log:printDebug(msg, keyValues = context);
    }
}

public isolated function warn(string msg, error? err = (), log:KeyValues context = {}) {
     if err is error {
        log:printWarn(msg, err, keyValues = context);
    } else {
        log:printWarn(msg, keyValues = context);
    }
}
