import { DeviceEventEmitter, NativeModules } from 'react-native';

const { SpeedCheckerPlugin } = NativeModules;

const SpeedChecker = {
  startTest: () => {
    SpeedCheckerPlugin.startTest();
  },
  addTestStartedListener: (event) => {
    DeviceEventEmitter.addListener('onTestStarted', event);
  },
};

export default SpeedChecker;
