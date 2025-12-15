enum HomeAppliancesStatus { initial, loading, success, failure }

class HomeAppliancesState {
  final HomeAppliancesStatus status;
  final List<Map<String, dynamic>> appliances;

  HomeAppliancesState({
    this.status = HomeAppliancesStatus.initial,
    this.appliances = const [],
  });

  HomeAppliancesState copyWith({
    HomeAppliancesStatus? status,
    List<Map<String, dynamic>>? appliances,
  }) {
    return HomeAppliancesState(
      status: status ?? this.status,
      appliances: appliances ?? this.appliances,
    );
  }
}
