import 'package:flutter_test/flutter_test.dart';
import 'package:futsalteammaker/features/onboarding/roster_parser.dart';

void main() {
  test('줄바꿈·쉼표·공백으로 나눈다', () {
    expect(parseRoster('김철수, 이영희\n박민수 최지훈'), ['김철수', '이영희', '박민수', '최지훈']);
  });

  test('번호·기호를 지우고 중복을 뺀다', () {
    expect(parseRoster('1. 김철수\n2) 이영희\n- 박민수\n• 김철수\n3'), [
      '김철수',
      '이영희',
      '박민수',
    ]);
  });

  test('이미 등록된 이름은 뺀다', () {
    expect(parseRoster('김철수 이영희', existing: ['김철수']), ['이영희']);
  });

  test('빈 입력', () {
    expect(parseRoster('  \n , '), isEmpty);
  });
}
