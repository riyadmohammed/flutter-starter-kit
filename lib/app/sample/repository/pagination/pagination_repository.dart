import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_app_general.dart';
import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_app_structural_component.dart';

class PaginationRepository {
  final PaginationServices _paginationServices = PaginationServices();

  Future<MyResponse> guestLogin(DeviceModel model) async {
    final response = await _paginationServices.guestLogin(model);

    if (response.data is Map<String, dynamic>) {
      final responseModel = ResponseModel.fromJson(response.data as Map<String, dynamic>);

      if (responseModel.result is Map<String, dynamic>) {
        final user = GuestLoginResponseModel.fromJson(responseModel.result);
        return MyResponse.complete(user);
      }
    }
    return response;
  }

  Future<MyResponse> getVenueList(VenueListingRequestModel model, String accessToken) async {
    final response = await _paginationServices.venueList(model, accessToken);

    if (response.data is Map<String, dynamic>) {
      final responseModel = ResponseModel.fromJson(response.data as Map<String, dynamic>);
      if (responseModel.result is Map<String, dynamic>) {
        final venueListResponseModel = VenueListResponseModel.fromJson(responseModel.result as Map<String, dynamic>);

        return MyResponse.complete(venueListResponseModel.data);
      }
    }
    return response;
  }
}
