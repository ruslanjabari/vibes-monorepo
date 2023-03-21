import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { useContext } from 'react';
import { LevelContext } from '../context';
// screen that shows numerical values instead of animation
const Num = () => {
  const ctx = useContext(LevelContext);

  // console.log("in num", ctx)
  return (
    <View style={styles.container}>
      <Text style={styles.text}>♥️ {ctx.heartRate}</Text>
      <View style={{ flexDirection: 'row', justifyContent: 'center', alignItems: 'center'}}>
        <Text style={[, styles.text, { fontSize: 32, paddingRight: 24, color: '#B02F26'}]}>HRV:</Text>
        <Text style={styles.text}>{ctx.hrv}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: '#111',
    paddingTop: 100,
    paddingBottom: 100,
  },
  text: {
    color: '#59ADA1',
    fontWeight: 'bold',
    fontSize: 82,
  },
});

export default Num;