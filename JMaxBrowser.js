import PropTypes from 'prop-types';
import React from 'react';
import {requireNativeComponent,NativeModules,View,Dimensions,Platform} from 'react-native';

export default class JMF1VideoViewBrower extends React.Component {
    static propTypes = {
        ...View.propTypes,
        path: PropTypes.string,
        conn: PropTypes.bool,
        start: PropTypes.bool
    }
   static defaultProps = {
    ...Platform.select({
        ios:{

        },
        android:{
        }
    }),

   }
    render() {
      return <JMF1Brower {...this.props} />;
    }
}
var JMF1Brower = requireNativeComponent('JMF1VideoView', JMF1VideoViewBrower);
