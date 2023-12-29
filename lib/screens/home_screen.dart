import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // 출석체크를 할 거리를 미터로 둠
  static const double distance = 150;
  // latitude - 위도 / longitude - 경도
  // LatLng - 위도와 경도를 가지는 클래스, 하나의 클래스로 값을 넣을 수 있음
  // 여의도 회사로 예시
  static const LatLng companyLatLng = LatLng(
    37.5233273,
    126.921252,
  );

  // 회사를 둘러싸는 원
  static Circle withinDistanceCircle = Circle(
    // 여러개의 원을 구분하는 고유한 값
    circleId: const CircleId(
      'withinDistanceCircle',
    ),
    center: companyLatLng,
    // 투명도 줘야 덮지 않음
    fillColor: Colors.blue.withOpacity(
      0.5,
    ),
    // 반지름은 출석체크를 할 거리를 미터로 둠
    radius: distance,
    // 원의 둘레의 색과 두께
    strokeColor: Colors.blue,
    strokeWidth: 1,
  );
  static Circle notWithinDistanceCircle = Circle(
    // 여러개의 원을 구분하는 고유한 값
    circleId: const CircleId(
      'notWithinDistanceCircle',
    ),
    center: companyLatLng,
    // 투명도 줘야 덮지 않음
    fillColor: Colors.red.withOpacity(
      0.5,
    ),
    // 반지름은 출석체크를 할 거리를 미터로 둠
    radius: distance,
    // 원의 둘레의 색과 두께
    strokeColor: Colors.red,
    strokeWidth: 1,
  );
  static Circle checkDoneCircle = Circle(
    // 여러개의 원을 구분하는 고유한 값
    circleId: const CircleId(
      'checkDoneCircle',
    ),
    center: companyLatLng,
    // 투명도 줘야 덮지 않음
    fillColor: Colors.green.withOpacity(
      0.5,
    ),
    // 반지름은 출석체크를 할 거리를 미터로 둠
    radius: distance,
    // 원의 둘레의 색과 두께
    strokeColor: Colors.green,
    strokeWidth: 1,
  );
  // 마커
  static Marker marker = const Marker(
    markerId: MarkerId(
      'marker',
    ),
    position: companyLatLng,
  );

  // 우주에서 바라보는 시점 == 카메라 포지션
  static const CameraPosition initialPostion = CameraPosition(
    // target에는 위도와 경도
    // zoom은 지도의 확대 정도
    target: companyLatLng,
    zoom: 15,
  );

  @override
  Widget build(BuildContext context) {
    // 지도 사용법
    return Scaffold(
      appBar: renderAppbar(),
      body: FutureBuilder(
        future: checkPermission(),
        builder: (
          BuildContext context,
          AsyncSnapshot snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data == '위치 권한이 허가되었습니다.') {
            return Column(
              children: [
                _CustomGoogleMap(
                  circle: withinDistanceCircle,
                  marker: marker,
                  initialPostion: initialPostion,
                ),
                const _ChoolCheckButton(),
              ],
            );
          } else {
            return Center(
              child: Text(snapshot.data),
            );
          }
        },
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
  final Circle circle;
  final Marker marker;
  final CameraPosition initialPostion;
  const _CustomGoogleMap({
    super.key,
    required this.initialPostion,
    required this.circle,
    required this.marker,
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
        // 내 위치
        myLocationEnabled: true,
        // 직접 만들거라서 false
        myLocationButtonEnabled: false,
        // 우리가 정의한 원들(Set이라 circleId가 중복이면 같은 원 취급)
        circles: {
          circle,
        },
        // 마커
        markers: {
          marker,
        },
      ),
    );
  }
}

Future<String> checkPermission() async {
  // 권한 요청의 응답에 따른 각각의 반환값을 지정
  final isLocationEnabled = await Geolocator.isLocationServiceEnabled();

  if (!isLocationEnabled) {
    return '위치 서비스를 활성화해주세요.';
  }
  // 현재 권한 상태를 확인
  LocationPermission checkedPermission = await Geolocator.checkPermission();

  if (checkedPermission == LocationPermission.denied) {
    // 권한을 요청
    checkedPermission = await Geolocator.requestPermission();

    if (checkedPermission == LocationPermission.denied) {
      return '위치 권한을 허용해주세요.';
    }
  }

  if (checkedPermission == LocationPermission.deniedForever) {
    return '앱의 위치 권한을 세팅에서 허용해주세요.';
  }

  return '위치 권한이 허가되었습니다.';
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
