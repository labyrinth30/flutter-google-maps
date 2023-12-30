import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool choolCheckDone = false;
  // 출석체크를 할 거리를 미터로 둠
  static const double okDistance = 150;
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
    radius: okDistance,
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
    radius: okDistance,
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
    radius: okDistance,
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

  // 출석체크 버튼을 눌렀을 때
  onChoolCheckButtonPressed() async {
    final result = await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('출석체크'),
          content: const Text('출석체크를 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  withinDistanceCircle = checkDoneCircle;
                });
                Navigator.pop(context, true);
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
    if (result == true) {
      setState(() {
        choolCheckDone = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 지도 사용법
    return Scaffold(
      appBar: renderAppbar(),
      // FutureBuilder의 Generic에는 Snapshot.data의 type이 들어감
      body: FutureBuilder<String>(
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
            // StreamBuilder
            return StreamBuilder<Position>(
                // 설정한 정확도에 따라 현재 위치가 변경될 때마다 Stream이 발생
                stream: Geolocator.getPositionStream(),
                builder: (context, snapshot) {
                  // geolocator에서 만들어놓은 계산식
                  bool isWithinRange = false;
                  if (snapshot.hasData) {
                    // 내 위치
                    final start = snapshot.data!;
                    // 회사 위치
                    const end = companyLatLng;
                    // 둘 사이의 거리가 distance보다 작으면 isWithinRange는 true
                    final distance = Geolocator.distanceBetween(
                      start.latitude,
                      start.longitude,
                      end.latitude,
                      end.longitude,
                    );
                    isWithinRange = distance <= okDistance;
                  }
                  return Column(
                    children: [
                      _CustomGoogleMap(
                        // 삼항 연산자 연달아 사용(지양)
                        circle: choolCheckDone
                            ? checkDoneCircle
                            : isWithinRange
                                ? withinDistanceCircle
                                : notWithinDistanceCircle,
                        marker: marker,
                        initialPostion: initialPostion,
                      ),
                      _ChoolCheckButton(
                        isWithinRange: isWithinRange,
                        choolChekDone: choolCheckDone,
                        onPressed: onChoolCheckButtonPressed,
                      ),
                    ],
                  );
                });
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
  final bool isWithinRange;
  final VoidCallback onPressed;
  final bool choolChekDone;
  const _ChoolCheckButton({
    super.key,
    required this.isWithinRange,
    required this.onPressed,
    required this.choolChekDone,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timelapse_outlined,
            size: 50,
            color: choolChekDone
                ? Colors.green
                : isWithinRange
                    ? Colors.blue
                    : Colors.red,
          ),
          const SizedBox(
            height: 20,
          ),
          // if문으로 바로 밑에 ElevatedButton을 띄울지 말지 결정
          if (isWithinRange && !choolChekDone)
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('출석체크'),
            ),
        ],
      ),
    );
  }
}
