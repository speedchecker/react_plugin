[![npm version](https://img.shields.io/npm/v/@speedchecker/react-native-plugin)](https://www.npmjs.com/package/@speedchecker/react-native-plugin)
![platforms](https://img.shields.io/badge/platforms-android%20%7C%20ios-yellowgreen.svg)
[![License](https://img.shields.io/badge/License-BSD%203--Clause-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

# React Native plugin for SpeedChecker SDK

SpeedChecker plugin allows developers to integrate speed test features into their own React Native apps. You can also try our native apps on [Google Play](https://play.google.com/store/apps/details?id=uk.co.broadbandspeedchecker\&hl=en\_US) and [App Store](https://itunes.apple.com/app/id658790195), they are powered by the latest Speedchecker SDK versions. More information about [SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)

## Features

* latency, download and upload speed of the user connection
* robust measuring of cellular, wireless and even local network
* testing details like the current speed and progress
* additional information like network type and location (see KPI list below in FAQ)
* included high-capacity servers provided and maintained by [SpeedChecker](https://www.speedchecker.com) or custom servers
* detailed statistics and reports by SpeedChecker

## Platform Support

| Android | iOS |
|:---:|:---:|
| supported :heavy_check_mark: | supported :heavy_check_mark: |

## Requirements

* Platform-specific requirements:
    * Android:
        *  minSDK version: 21 or higher
        *  Location permissions
    * iOS:
        * Xcode 13.3.1 or later
        * Development Target 11.0 or later

## Permission requirements

Free version of the plugin requires location permission to be able to perform a speed test. You need to handle location permission in your app level.
Check out our [location policy](https://github.com/speedchecker/react_plugin/wiki/Privacy-&-consent)

## Table of contents:
* [Installing](#installing)
* [How to use](#how-to-use)
* [Uninstalling](#uninstalling)

## Installing

### 1. Create a React Native project
```
npx react-native init [project folder]
```

### 2. Go to project directory
```
cd [project folder]
```

### 3. Install the plugin from npm repository
````
npm i @speedchecker/react-native-plugin -- save
````

### 4. Link the plugin to your React Native project
````
npm link @speedchecker/react-native-plugin
````

### 5. Run the project
```
react-native run-android
react-native run-ios
```

## How to use

#### 1. Import SpeedCheckerPlugin in your App.tsx file.
````
import SpeedCheckerPlugin from '@speedchecker/react-native-plugin';
````

#### 2. Listen events from SpeedCheckerPlugin and all variables you need to store speed test results
````
const [status, setStatus] = useState('');
  const [ping, setPing] = useState('');
  const [currentSpeed, setCurrentSpeed] = useState('');
  const [download, setDownload] = useState('');
  const [upload, setUpload] = useState('');
  const [server, setServer] = useState('');
  const [connectionType, setConnectionType] = useState('');

  useEffect(() => {
    return () => {
      SpeedCheckerPlugin.removeTestStartedListener();
    };
  }, []);
````

### 3. To start speed test by event (e.g. button click), you need to import the plugin and add "startTest" method to your App.tsx file:
````
const startTest = () => {
    SpeedCheckerPlugin.addTestStartedListener((event: {
      status: React.SetStateAction<string>;
      ping: React.SetStateAction<string>;
      currentSpeed: React.SetStateAction<string>;
      downloadSpeed: React.SetStateAction<string>;
      uploadSpeed: React.SetStateAction<string>;
      server: React.SetStateAction<string>;
      connectionType: React.SetStateAction<string>;
     }) => {
      setStatus(event.status || '');
      setPing(event.ping);
      setCurrentSpeed(event.currentSpeed);
      setDownload(event.downloadSpeed);
      setUpload(event.uploadSpeed);
      setServer(event.server);
      setConnectionType(event.connectionType);
    });
    SpeedCheckerPlugin.startTest();
  };
````
### 4. To stop speed test, add "stopTest" method to your App.tsx file:
````
 const stopTest = () => {
    SpeedCheckerPlugin.stopTest();
    setStatus('Speed Test stopped');
    SpeedCheckerPlugin.removeTestStartedListener();
  };
````

## Uninstalling
To uninstall the plugin, run the following commands
```
npm unlink @speedchecker/react-native-plugin
npm uninstall @speedchecker/react-native-plugin --save
```

## Demo application

Please check our [demo application](https://github.com/speedchecker/react_plugin) in React Native which includes basic speed test functionality.

## License

SpeedChecker is offering different types of licenses:

| Items                             | Free                          | Basic                                             | Advanced                                                          |
| --------------------------------- | ----------------------------- | ------------------------------------------------- | ----------------------------------------------------------------- |
| Speed Test Metrics                | Download / Upload / Latency   | Download / Upload / Latency / Jitter              | Download / Upload / Latency / Jitter                              |
| Accompanying Metrics              | Device / Network KPIs         | Device / Network KPIs                             | Device / Network KPIs / Advanced Cellular KPIs                    |
| Test Customization                | -                             | test duration, multi-threading, warm-up phase etc | test duration, multi-threading, warm-up phase etc                 |
| Location Permission               | Required location permissions | -                                                 | -                                                                 |
| Data Sharing Requirement          | Required data sharing         | -                                                 | -                                                                 |
| Measurement Servers               | -                             | Custom measurement servers                        | Custom measurement servers                                        |
| Background and passive collection | -                             | -                                                 | Background and Passive data collection                            |
| Cost                              | **FREE**                      | 1,200 EUR per app per year                        | Cost: [**Enquire**](https://www.speedchecker.com/contact-us.html) |

## FAQ

### **Is the SDK free to use?**

Yes! But the SDK collects data on network performance from your app and shares it with SpeedChecker and our clients. The free SDK version requires and
enabled location. Those restrictions are not in the Basic and Advanced versions

### **Do you have also native SDKs?**

Yes, we have both [Android](https://github.com/speedchecker/speedchecker-sdk-android) and [iOS](https://github.com/speedchecker/speedchecker-sdk-ios)
SDKs.

### **Do you provide other types of tests?**

Yes! YouTube video streaming, Voice over IP and other tests are supported by our native SDK libraries. Check out our [Android](https://github.com/speedchecker/speedchecker-sdk-android/wiki/API-documentation) and [iOS](https://github.com/speedchecker/speedchecker-sdk-ios/wiki/API-documentation) API documentation

### **Do you provide free support?**

No, we provide support only on Basic and Advanced plans

### **What are all the metrics or KPIs that you can get using our native SDKs?**

The free version of our plugin allows getting basic metrics which are described in
this [API documentation](https://github.com/speedchecker/react_plugin/wiki/API-documentation)

[Full list of our KPIs for Basic and Advanced versions](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/list-of-kpis)

### **Do you host all infrastructure for the test?**

Yes, you do not need to run any servers. We provide and maintain a network of high-quality servers and CDNs to ensure the testing is accurate. If you
wish to configure your own server, this is possible on Basic and Advanced plans.

### **How do you measure the speed?**

See our [measurement methodology](https://docs.speedchecker.com/measurement-methodology-links/u21ongNGAYLb6eo7cqjY/kpis-and-measurements/data-collection-methodologies)

## What's next?

Please contact us for more details and license requirements.

* [More information about SpeedChecker SDKs](https://www.speedchecker.com/speed-test-tools/mobile-apps-and-sdks.html)
* [API documentation](https://github.com/speedchecker/react_plugin/wiki/API-documentation)
* [Buy license](https://www.speedchecker.com/contact-us.html)
* [Contact us](https://www.speedchecker.com/contact-us.html)