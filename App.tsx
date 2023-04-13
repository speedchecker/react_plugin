import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, DeviceEventEmitter } from 'react-native';

import SpeedCheckerPlugin from './SpeedCheckerPlugin';
import { Double } from 'react-native/Libraries/Types/CodegenTypes';


const App = () => {

  const [status, setStatus] = useState('');
  const [ping, setPing] = useState('');
  const [currentSpeed, setcurrentSpeed] = useState('');
  const [download, setDownload] = useState('');
  const [upload, setUpload] = useState('');
  const [server, setServer] = useState('');
  const [connectionType, setConnectionType] = useState('');

  useEffect(() => {
    SpeedCheckerPlugin.addTestStartedListener((event: {
      status: React.SetStateAction<string>;
      ping: React.SetStateAction<number>;
      currentSpeed: React.SetStateAction<number>;
      downloadSpeed: React.SetStateAction<number>;
      uploadSpeed: React.SetStateAction<number>;
      server: React.SetStateAction<string>;
      connectionType: React.SetStateAction<string>;
     }) => {
      setStatus(event.status || '');
      setPing(event.ping + ' ms');
      setcurrentSpeed(event.currentSpeed + ' Mbps');
      setDownload(event.downloadSpeed + ' Mbps');
      setUpload(event.uploadSpeed + ' Mbps');
      setServer(event.server);
      setConnectionType(event.connectionType);
    });
    return () => {
      DeviceEventEmitter.removeAllListeners('onTestStarted');
    };
  }, []);

  const startTest = () => {
    SpeedCheckerPlugin.startTest();
  };

  return (
    <View style={styles.container}>
      <Text style={styles.statusText}>{status}</Text>
      <Text style={styles.resultText}>Ping: {ping}</Text>
      <Text style={styles.resultText}>Current speed: {currentSpeed}</Text>
      <Text style={styles.resultText}>Download speed: {download}</Text>
      <Text style={styles.resultText}>Upload speed: {upload}</Text>
      <Text style={styles.resultText}>Server: {server}</Text>
      <Text style={styles.resultText}>Connection type: {connectionType}</Text>
      <TouchableOpacity style={styles.button} onPress={startTest}>
        <Text style={styles.buttonText}>Start Test</Text>
      </TouchableOpacity>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  statusText: {
    fontSize: 24,
    fontWeight: 'bold',
    textAlign: 'center',
  },
  resultText: {
    fontSize: 18,
    textAlign: 'center',
  },
  button: {
    marginTop: 20,
    backgroundColor: 'blue',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
  },
  buttonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
  },
});

export default App;
