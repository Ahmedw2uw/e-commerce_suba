import 'package:e_commerce/core/utilits/app_assets.dart';
import 'package:e_commerce/features/auth/services/supabase_service.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/home_appliances/home_appliances_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeAppliancesCubit extends Cubit<HomeAppliancesState> {
  final SupabaseService service;

  HomeAppliancesCubit(this.service) : super(HomeAppliancesState());

  Future<void> loadAppliances() async {
    emit(state.copyWith(status: HomeAppliancesStatus.loading));
    try {
      final products = await SupabaseService.getProductsByCategory(13);
      final appliances = products.map((p) => {
        'id': p.id,
        'name': p.name,
        'image': p.images.isNotEmpty ? p.images[0] : null,
        'price': p.price,
      }).toList();
      if (appliances.isEmpty) {
        appliances.addAll([
          {'image': AppImages.laptop, 'isAsset': true},
          {'image': AppImages.headphones, 'isAsset': true},
          {'image': AppImages.beauty, 'isAsset': true},
          {'image': AppImages.men, 'isAsset': true},
        ]);
      }
      emit(state.copyWith(
        status: HomeAppliancesStatus.success,
        appliances: appliances,
      ));
    } catch (e) {
      emit(state.copyWith(status: HomeAppliancesStatus.failure));
    }
  }
}
