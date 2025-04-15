import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_app_general.dart';
import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_app_screens.dart';
import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_app_structural_component.dart';
import 'package:dumbdumb_flutter_app/app/assets/exporter/importer_routing.dart';

class PaginatedListPage extends BaseStatefulPage {
  const PaginatedListPage({super.key});

  @override
  State<PaginatedListPage> createState() => _PaginatedListPageState();
}

class _PaginatedListPageState extends BaseStatefulState<PaginatedListPage> {
  // Controller for managing the pagination state.
  final PagingController<int, VenueListModel> _pagingController = PagingController(
    firstPageKey: GeneralConstant.defaultPageKey,
    // Number of items from the end of the list to trigger the next page load.
    // This ensures smooth scrolling by pre-loading items before the user reaches the end of the list.
    invisibleItemsThreshold: 10,
  );

  @override
  void initState() {
    super.initState();

    // Check if token is available and fetch venue list
    final viewModel = context.read<VenueListingViewModel>();

    tryLoad(context, () async {
      await viewModel.guestLogin();
    }).then((val) => loadVenueList());

    // Add a listener to handle page requests for pagination
    _pagingController.addPageRequestListener((pageKey) {
      loadVenueList(pageKey: pageKey);
    });
  }

  @override
  void dispose() {
    // Dispose of the paging controller to prevent memory leaks.
    _pagingController.dispose();
    super.dispose();
  }

  void loadVenueList({int pageKey = GeneralConstant.defaultPageKey}) {
    tryLoad(context, () async {
      final viewModel = context.read<VenueListingViewModel>();
      await viewModel.getVenueList(pageKey, context.read<VenueListingViewModel>().token ?? '');
    });
  }

  @override
  Widget body() {
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [const SizedBox(height: 28), Expanded(child: buildVenueList())]));
  }

  Widget buildVenueList() {
    final imageWidth = width() * 0.3;
    final imageHeight = imageWidth * 1.4;
    return Selector<VenueListingViewModel, PagingState<int, VenueListModel>>(
        selector: (context, vm) => vm.venuePagingState,
        builder: (context, pagingState, child) {
          return PagedListView<int, VenueListModel>(
              pagingController: _pagingController..value = pagingState,
              builderDelegate: PagedChildBuilderDelegate<VenueListModel>(
                  noItemsFoundIndicatorBuilder: (_) => Center(child: Text(S.current.noVenueFound)),
                  itemBuilder: (context, venue, index) {
                    return Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Column(children: [
                          Row(children: [
                            Container(
                                height: imageHeight,
                                width: imageWidth,
                                clipBehavior: Clip.hardEdge,
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                                child: NetworkImageLoader(imageUrl: venue.thumbnailUrl ?? '', fit: BoxFit.cover)),
                            const SizedBox(width: 16),
                            Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(venue.name ?? '',
                                  maxLines: 2,
                                  style: context.theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w500, fontSize: 16, color: AppPalette.blue.shade900)),
                              const SizedBox(height: 8),
                              const SizedBox(height: 12),
                              Text('${venue.distance?.toStringAsFixed(1) ?? 0} km',
                                  maxLines: 2,
                                  style: context.theme.textTheme.bodyMedium
                                      ?.copyWith(fontSize: 12, fontWeight: FontWeight.w400))
                            ]))
                          ]),
                          const Divider(thickness: 0.2, color: AppPalette.gray)
                        ]));
                  }));
        });
  }

  @override
  AppBar? appbar() => AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      leading: TouchableOpacity(onPressed: () => context.go(AppRouter.login), child: const Icon(Icons.arrow_back)),
      titleTextStyle:
          context.theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700, color: Colors.black, fontSize: 18));

  @override
  @override
  bool topSafeAreaEnabled() => true;
}
