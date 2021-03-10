import {
  requireNativeComponent,
  View,
  Platform,
  DeviceEventEmitter
} from 'react-native';
import React, { Component } from 'react';
import PropTypes from 'prop-types';
import resolveAssetSource from 'react-native/Libraries/Image/resolveAssetSource';

export default class RNJMF1MonitorView extends Component {
  static propTypes = {
    ...View.propTypes,
    image: PropTypes.number
  };

  _onChange(event) {
    if (typeof this.props[event.nativeEvent.type] === 'function') {
      this.props[event.nativeEvent.type](event.nativeEvent.params);
    }
  }

  render() {
    let image = this.props.image;
    if (this.props.image) {
      image = resolveAssetSource(this.props.image) || {};
    }
    
    return <JMF1MonitorView {...this.props} onChange={this._onChange.bind(this)}
      style={Platform.OS === 'ios' ? {backgroundColor:'black',...this.props.style} : {...this.props.style, backgroundColor:'#FF000000'}}
      image={image} />;
  }
}

const JMF1MonitorView = requireNativeComponent('JMF1Monitor', RNJMF1MonitorView, {
  nativeOnly: {onChange: true}
});

