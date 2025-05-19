import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class videocall extends StatefulWidget {
  const videocall({super.key, required this.title});

  final String title;
  @override
  State<videocall> createState() => _videocallState();
}

class _videocallState extends State<videocall> {
   bool _isMuted = false;
   void _toggleMute() {
  setState(() {
    _isMuted = !_isMuted;
  });
  _engine.muteLocalAudioStream(_isMuted);
}

@override
  void initState() {
  initAgora();
  super.initState();
  }

  @override
  void dispose() {
    _dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text(widget.title),
      ),
     body: Stack(
  children: [
    Center(child: _remoteVideo()),
    Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 100,
        height: 150,
        child: Center(
          child: localUserJoined
              ? AgoraVideoView(
                  controller: VideoViewController(
                    rtcEngine: _engine,
                    canvas: const VideoCanvas(uid: 0),
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    ),
    // Call controls
    Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute/Unmute button
            CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: Icon(
                  _isMuted ? Icons.mic_off : Icons.mic,
                  color: Colors.white,
                ),
                onPressed: _toggleMute,
              ),
            ),
            // End Call button
            CircleAvatar(
              backgroundColor: Colors.red,
              child: IconButton(
                icon: const Icon(Icons.call_end, color: Colors.white),
                onPressed: () {
                  _dispose();
                  Navigator.pop(context);
                },
              ),
            ),
            // Switch camera button
            CircleAvatar(
              backgroundColor: Colors.black54,
              child: IconButton(
                icon: const Icon(Icons.cameraswitch, color: Colors.white),
                onPressed: () {
                  _engine.switchCamera();
                },
              ),
            ),
          ],
        ),
      ),
    ),
  ],
),

    );
  }



  late RtcEngine _engine;
  int? _remoteUid;
  bool localUserJoined = false;


  Future<void> initAgora() async {
    await [Permission.microphone, Permission.camera].request();
    _engine =  createAgoraRtcEngine();
    await _engine.initialize(const RtcEngineContext(
      appId: "7fe424e16f2741af80200fb75720e8d3",
      channelProfile: ChannelProfileType.channelProfileCommunication,
    ));
    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.joinChannel(
      token: "007eJxTYPh3Vezq+pB5D/xTOepn6J/LYX+heUpHxTO4cVoI7zSrVm8FBvO0VBMjk1RDszQjcxPDxDQLAyMDg7Qkc1NzI4NUixTjnztUMhoCGRl+r5zHysgAgSA+J0NZZkpqfklqcQkDAwCy7iEM",
      channelId: "videotest",
      options: const ChannelMediaOptions(
          autoSubscribeVideo: true,
          autoSubscribeAudio: true,
          publishCameraTrack: true,
          publishMicrophoneTrack: true,
          clientRoleType: ClientRoleType.clientRoleBroadcaster),
      uid: 0, );
    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          debugPrint("local user ${connection.localUid} joined");
          setState(() {
            localUserJoined = true;
          });
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          debugPrint("remote user $remoteUid joined");
          setState(() {
            _remoteUid = remoteUid;
          });
        },
        onUserOffline: (RtcConnection connection, int remoteUid,
            UserOfflineReasonType reason) {
          debugPrint("remote user $remoteUid left channel");
          setState(() {
            _remoteUid = null;
          });
        },
      ),
    );

  }

  Widget _remoteVideo() {
    if (_remoteUid != null) {
      return AgoraVideoView(
        controller: VideoViewController.remote(
          rtcEngine: _engine,
          canvas: VideoCanvas(uid: _remoteUid),
          connection: const RtcConnection(channelId: "videotest"),
        ),
      );
    } else {
      return const Text(
        'Please wait for remote user to join',
        textAlign: TextAlign.center,
      );
    }
  }

Future<void> _dispose() async {
  await _engine.leaveChannel();
  await _engine.release();
}


}