// main index.js

import { NativeEventEmitter, NativeModules } from 'react-native';

const { SpeedCheckerPlugin } = NativeModules;

const speedcheckerEvents = new NativeEventEmitter(SpeedCheckerPlugin);

const SpeedChecker = {
    startTest: () => {
        SpeedCheckerPlugin.startTest();
    },
    startTestWithTestType: (speedTestType) => {
        SpeedCheckerPlugin.startTestWithTestType(speedTestType);
    },
    startTestWithCustomServer: (customServerParams) => {
        SpeedCheckerPlugin.startTestWithCustomServer(customServerParams);
    },
    stopTest: () => {
        SpeedCheckerPlugin.stopTest();
    },
    addTestStartedListener: (event) => {
        const subscription = speedcheckerEvents.addListener('onTestStarted', (eventData) => {
            const { status, ping, currentSpeed, downloadSpeed, uploadSpeed, server, connectionType } = eventData;
      
            const newEvent = {
                status: status || '',
                ping: ping !== undefined ? ping + ' ms' : '',
                currentSpeed: currentSpeed !== undefined ? currentSpeed + ' Mbps' : '',
                downloadSpeed: downloadSpeed !== undefined ? downloadSpeed + ' Mbps' : '',
                uploadSpeed: uploadSpeed !== undefined ? uploadSpeed + ' Mbps' : '',
                server: server || '',
                connectionType: connectionType || '',
            };
            event(newEvent);
        });
        return subscription;
    },
    removeTestStartedListener: (subscription) => {
        if (subscription) {
            subscription.remove();
        }
    }
  };

export default SpeedChecker;