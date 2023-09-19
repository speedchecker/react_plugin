/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 *
 * @format
 */

import React, { useState, useEffect } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, EmitterSubscription } from 'react-native';

import SpeedChecker from '@speedchecker/react-native-plugin';

const App = () => {

  const [status, setStatus] = useState('');
  const [ping, setPing] = useState('');
  const [currentSpeed, setcurrentSpeed] = useState('');
  const [download, setDownload] = useState('');
  const [upload, setUpload] = useState('');
  const [server, setServer] = useState('');
  const [connectionType, setConnectionType] = useState('');

  let testStartedSubscription: EmitterSubscription;

  useEffect(() => {
    return () => {
      SpeedChecker.removeTestStartedListener(testStartedSubscription);
    };
  }, []);

  const startTest = () => {
    testStartedSubscription = SpeedChecker.addTestStartedListener((event: {
      status: React.SetStateAction<string>;
      ping: React.SetStateAction<string>;
      currentSpeed: React.SetStateAction<string>;
      downloadSpeed: React.SetStateAction<string>;
      uploadSpeed: React.SetStateAction<string>;
      server: React.SetStateAction<string>;
      connectionType: React.SetStateAction<string>;
      error: React.SetStateAction<string>;
     }) => {      
      setStatus(event.status || '');
      setPing(event.ping);
      setcurrentSpeed(event.currentSpeed);
      setDownload(event.downloadSpeed);
      setUpload(event.uploadSpeed);
      setServer(event.server);
      setConnectionType(event.connectionType);
    });
    SpeedChecker.startTest();
  };

  const stopTest = () => {
    SpeedChecker.stopTest();
    setStatus('Speed Test stopped');
    SpeedChecker.removeTestStartedListener(testStartedSubscription);
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
      <View style={styles.buttonsContainer}>
        <TouchableOpacity style={styles.button} onPress={startTest}>
          <Text style={styles.buttonText}>Start Test</Text>
        </TouchableOpacity>
        <TouchableOpacity style={[styles.button, styles.stopButton]} onPress={stopTest}>
          <Text style={styles.buttonText}>Stop Test</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'flex-start',
    marginHorizontal: 30,
  },
  statusText: {
    fontSize: 24,
    fontWeight: 'bold',
    alignSelf: 'center',
  },
  resultText: {
    fontSize: 18,
    textAlign: 'center',
  },
  buttonsContainer: {
    flexDirection: 'row',
    marginTop: 20,
  },
  button: {
    backgroundColor: 'blue',
    paddingVertical: 10,
    paddingHorizontal: 20,
    borderRadius: 5,
    flex: 1,
    marginHorizontal: 5,
  },
  stopButton: {
    backgroundColor: 'red',
  },
  buttonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: 'white',
    textAlign: 'center',
  },
});

export default App;
