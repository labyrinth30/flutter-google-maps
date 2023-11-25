import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // latitude - 위도 / longitude - 경도
  // LatLng - 위도와 경도를 가지는 클래스, 하나의 클래스로 값을 넣을 수 있음
  // 여의도 회사로 예시
  static const LatLng companyLatLng = LatLng(
    37.5233273,
    126.921252,
  );
  // 우주에서 바라보는 시점 == 카메라 포지션
  static const CameraPosition initialPostion = CameraPosition(
    // target에는 위도와 경도
    // zoom은 지도의 확대 정도
    target: companyLatLng,
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    // 지도 사용법
    return Scaffold(
      appBar: renderAppbar(),
      body: const Column(
        children: [
          _CustomGoogleMap(
            initialPostion: initialPostion,
          ),
          _ChoolCheckButton(),
        ],
      ),
    );
  }

  AppBar renderAppbar() {
    return AppBar(
      title: const Text(
        '오늘도 출근',
        style: TextStyle(
          color: Colors.blue,
          fontWeight: FontWeight.w700,
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}

class _CustomGoogleMap extends StatelessWidget {
  final CameraPosition initialPostion;
  const _CustomGoogleMap({
    super.key,
    required this.initialPostion,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: GoogleMap(
        // 처음 지도를 켰을 때의 위치
        initialCameraPosition: initialPostion,
        // 지도의 타입
        mapType: MapType.normal,
      ),
    );
  }
}

class _ChoolCheckButton extends StatelessWidget {
  const _ChoolCheckButton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Expanded(
      child: Text('출근'),
    );
  }
}
