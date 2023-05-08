import { DeviceEventEmitter, NativeModules } from 'react-native';

const { SpeedCheckerPlugin } = NativeModules;

const SpeedChecker = {
  startTest: () => {
    SpeedCheckerPlugin.startTest();
  },
  stopTest: () => {
    SpeedCheckerPlugin.stopTest();
  },
  addTestStartedListener: (event) => {
  DeviceEventEmitter.addListener('onTestStarted', (eventData) => {
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
},

  removeTestStartedListener: () => {
    DeviceEventEmitter.removeAllListeners('onTestStarted');
  }
};

export default SpeedChecker;