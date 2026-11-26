import 'coach_marks.dart';

/// 화면별 튜토리얼 말풍선 문구 (SPEC F14). 화면에 없는 대상은 자동으로 건너뛴다.
abstract final class TutorialSteps {
  static const groupList = [
    CoachStep(
      'groups.create',
      '모임 만들기',
      '풋살 모임을 만들고 선수 명단과 능력치를 등록해요. 모임은 여러 개 만들 수 있어요.',
    ),
    CoachStep(
      'groups.card',
      '모임 카드',
      '탭하면 모임으로 들어가요. 길게 누르면 이름을 바꾸거나 이 폰에서 삭제할 수 있어요.',
    ),
    CoachStep(
      'groups.join',
      '초대 링크로 참여',
      '다른 사람이 보낸 초대 링크로 그 모임의 선수 명단을 그대로 받아요. (곧 제공돼요)',
    ),
  ];

  static const groupHome = [
    CoachStep(
      'home.format',
      '오늘 매치 시작',
      '5 vs 5 또는 6 vs 6을 고르면, 오늘 나온 사람을 출전 덱에 올리는 화면으로 넘어가요.',
    ),
    CoachStep(
      'home.onboarding',
      '설정 마무리하기',
      '건너뛴 선수 명단·간단 스펙 입력을 이어서 할 수 있어요.',
    ),
    CoachStep(
      'shell.players',
      '선수',
      '선수를 등록하고 능력치를 고쳐요. 항상 같은 팀/다른 팀으로 나눌 선수도 여기서 정해요.',
    ),
    CoachStep(
      'shell.settings',
      '설정',
      '모임 이름·아이콘·기본 경기 방식을 바꾸고, 사용법을 다시 볼 수 있어요.',
    ),
    CoachStep('shell.groups', '모임 목록', '다른 모임으로 이동해요.'),
  ];

  static List<CoachStep> players({required bool canSeeStats}) => [
    const CoachStep(
      'players.add',
      '선수 추가',
      '이름·멤버 구분(주/일반)·포지션(픽소·아라·피보)·능력치를 입력해 새 선수를 등록해요.',
    ),
    if (canSeeStats)
      const CoachStep(
        'players.list',
        'OVR = 종합 능력치',
        '이름 옆 숫자는 OVR이에요. 슈팅·드리블·스피드·패스·피지컬·창의력·협력 7개 능력치의 '
            '평균으로 1.0~5.0점이에요. "간단" 표시는 종합 점수 하나만 입력된 선수예요.',
      )
    else
      const CoachStep(
        'players.list',
        '선수 목록',
        '주멤버가 먼저 보여요. 탭하면 선수 정보를 보고 고칠 수 있어요.',
      ),
    const CoachStep(
      'players.constraints',
      '같은 팀/다른 팀',
      '카풀하는 사이는 항상 같은 팀, 에이스 둘은 항상 다른 팀처럼 매번 적용할 조건을 정해요.',
    ),
  ];

  static const deck = [
    CoachStep(
      'deck.selectAll',
      '주멤버 전체 선택',
      '자주 나오는 주멤버를 한 번에 출전 덱에 올려요. 안 온 사람만 다시 탭해서 빼면 돼요.',
    ),
    CoachStep(
      'deck.regular',
      '선수 체크',
      '오늘 나온 사람을 탭해서 출전 덱에 올려요. 다시 탭하면 빠져요. 위쪽 검색으로 빨리 찾을 수 있어요.',
    ),
    CoachStep(
      'deck.panel',
      '출전 덱',
      '올라간 선수와 포지션 분포가 보여요. 고르던 덱은 앱을 꺼도 남아 있어요.',
    ),
    CoachStep('deck.guest', '게스트', '오늘만 온 사람은 이름·종합 점수·포지션만 넣어 추가해요.'),
    CoachStep('deck.next', '다음', '팀 수와 골키퍼 방식을 정하러 가요.'),
  ];

  static const teamSetup = [
    CoachStep(
      'setup.teamCount',
      '팀 수',
      '2팀이 기본이고 + 버튼으로 4팀까지 늘려요. 팀별 인원이 바로 계산되고, '
          '인원이 모자란 팀은 평균 실력의 1명을 빌려 온 것으로 보정해요.',
    ),
    CoachStep(
      'setup.keeper',
      '골키퍼',
      '기본은 돌아가며 키퍼(로테이션)예요. 키퍼 고정을 고르면 팀마다 키퍼를 지정할 수 있어요.',
    ),
    CoachStep('setup.day', '오늘만 적용할 조건', '오늘만 같은 팀이나 다른 팀으로 나눌 선수가 있다면 추가해요.'),
    CoachStep(
      'setup.make',
      '팀 짜기',
      '구장 화면으로 넘어가요. 거기서 ⚡ 자동 편성을 누르면 선수들이 자리에 배치돼요.',
    ),
  ];

  static const pitch = [
    CoachStep(
      'pitch.deck',
      '출전 덱',
      '오늘 나온 선수들이에요. 자동 편성을 누르면 이 선수들이 구장의 포지션 원으로 들어가요.',
    ),
    CoachStep(
      'pitch.court',
      '팀 구장',
      '팀마다 반쪽 구장이 나란히 보여요. 원은 GK·픽소·아라·피보 자리이고, 아래쪽이 우리 골대예요. '
          '🔄는 처음 키퍼를 볼 사람, 🧤는 고정 키퍼, 주황 ↔ 표시는 선호 포지션이 아닌 자리예요.',
    ),
    CoachStep('pitch.auto', '⚡ 자동 편성', '누르면 실력 균형이 맞도록 팀을 나누고 자리까지 배치해요.'),
    CoachStep(
      'pitch.score',
      '밸런스 점수',
      '팀 간 균형을 100점 만점으로 보여줘요. 팀 평균 OVR(전력)·공격력·수비력이 비슷할수록, '
          '선수가 자기 포지션에 설수록 높아요. 오른쪽 숫자로 다른 편성안(최대 3개)을 비교해요.',
    ),
    CoachStep('pitch.shuffle', '다시 섞기', '마음에 들지 않으면 이미 본 것과 다른 조합을 새로 만들어요.'),
    CoachStep(
      'pitch.court',
      '직접 바꾸기',
      '원을 끌어 다른 원(다른 팀도 가능)이나 후보 칸에 놓으면 맞바꿔요. 점수는 바로 다시 계산돼요. '
          '원을 길게 누르면 📌 고정되어, 다시 섞어도 그 자리에 남아요. 팀 이름을 누르면 이름·조끼 색을 바꿔요.',
    ),
    CoachStep(
      'pitch.confirm',
      '확정·공유',
      '편성이 마음에 들면 확정해요. 단톡방에 텍스트나 구장 이미지로 공유하고, '
          '다음 편성 때 이번과 같은 조합을 피하는 데 쓰여요.',
    ),
    CoachStep(
      'pitch.undo',
      '되돌리기',
      '방금 바꾼 것을 되돌리거나 다시 할 수 있어요. 초기화를 누르면 자동 편성 결과로 돌아가요.',
    ),
  ];
}
