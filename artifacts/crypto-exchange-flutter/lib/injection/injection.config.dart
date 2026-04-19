// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:mobile/core/network/api_client.dart' as _i456;
import 'package:mobile/core/network/dio_client.dart' as _i873;
import 'package:mobile/core/network/network_info.dart' as _i821;
import 'package:mobile/core/services/chart_service.dart' as _i881;
import 'package:mobile/core/services/favorites_service.dart' as _i271;
import 'package:mobile/core/services/futures_websocket_service.dart' as _i244;
import 'package:mobile/core/services/global_notification_service.dart' as _i711;
import 'package:mobile/core/services/maintenance_service.dart' as _i1;
import 'package:mobile/core/services/market_service.dart' as _i903;
import 'package:mobile/core/services/navigation_service.dart' as _i16;
import 'package:mobile/core/services/notification_service.dart' as _i848;
import 'package:mobile/core/services/price_animation_service.dart' as _i794;
import 'package:mobile/core/services/screenshot_service.dart' as _i542;
import 'package:mobile/core/services/stripe_service.dart' as _i882;
import 'package:mobile/core/services/trading_websocket_service.dart' as _i458;
import 'package:mobile/core/services/websocket_service.dart' as _i314;
import 'package:mobile/features/addons/blog/data/datasources/blog_remote_datasource.dart'
    as _i497;
import 'package:mobile/features/addons/blog/data/services/blog_author_service.dart'
    as _i771;
import 'package:mobile/features/addons/blog/presentation/bloc/authors_bloc.dart'
    as _i962;
import 'package:mobile/features/addons/blog/presentation/bloc/blog_bloc.dart'
    as _i299;
import 'package:mobile/features/addons/ecommerce/data/datasources/discount_remote_datasource.dart'
    as _i449;
import 'package:mobile/features/addons/ecommerce/data/datasources/ecommerce_local_datasource.dart'
    as _i1031;
import 'package:mobile/features/addons/ecommerce/data/datasources/ecommerce_remote_data_source.dart'
    as _i702;
import 'package:mobile/features/addons/ecommerce/data/datasources/ecommerce_remote_datasource.dart'
    as _i202;
import 'package:mobile/features/addons/ecommerce/data/repositories/discount_repository_impl.dart'
    as _i681;
import 'package:mobile/features/addons/ecommerce/data/repositories/ecommerce_repository_impl.dart'
    as _i754;
import 'package:mobile/features/addons/ecommerce/domain/repositories/discount_repository.dart'
    as _i222;
import 'package:mobile/features/addons/ecommerce/domain/repositories/ecommerce_repository.dart'
    as _i457;
import 'package:mobile/features/addons/ecommerce/domain/usecases/add_review_usecase.dart'
    as _i358;
import 'package:mobile/features/addons/ecommerce/domain/usecases/add_to_cart_usecase.dart'
    as _i238;
import 'package:mobile/features/addons/ecommerce/domain/usecases/add_to_wishlist_usecase.dart'
    as _i869;
import 'package:mobile/features/addons/ecommerce/domain/usecases/clear_cart_usecase.dart'
    as _i922;
import 'package:mobile/features/addons/ecommerce/domain/usecases/download_digital_product_usecase.dart'
    as _i812;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_cart_usecase.dart'
    as _i409;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_categories_usecase.dart'
    as _i901;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_order_by_id_usecase.dart'
    as _i82;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_orders_usecase.dart'
    as _i648;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_products_by_category_usecase.dart'
    as _i514;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_products_usecase.dart'
    as _i759;
import 'package:mobile/features/addons/ecommerce/domain/usecases/get_wishlist_usecase.dart'
    as _i380;
import 'package:mobile/features/addons/ecommerce/domain/usecases/place_order_usecase.dart'
    as _i586;
import 'package:mobile/features/addons/ecommerce/domain/usecases/remove_from_cart_usecase.dart'
    as _i959;
import 'package:mobile/features/addons/ecommerce/domain/usecases/remove_from_wishlist_usecase.dart'
    as _i920;
import 'package:mobile/features/addons/ecommerce/domain/usecases/track_order_usecase.dart'
    as _i523;
import 'package:mobile/features/addons/ecommerce/domain/usecases/update_cart_item_quantity_usecase.dart'
    as _i876;
import 'package:mobile/features/addons/ecommerce/domain/usecases/validate_discount_usecase.dart'
    as _i854;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/add_review_cubit.dart'
    as _i363;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/cart/cart_bloc.dart'
    as _i1045;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/categories/categories_bloc.dart'
    as _i898;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/category_products/category_products_bloc.dart'
    as _i932;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/checkout/checkout_bloc.dart'
    as _i1018;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/order_detail/order_detail_bloc.dart'
    as _i314;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/orders/orders_bloc.dart'
    as _i863;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/products/products_bloc.dart'
    as _i152;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/shop/shop_bloc.dart'
    as _i399;
import 'package:mobile/features/addons/ecommerce/presentation/bloc/wishlist/wishlist_bloc.dart'
    as _i481;
import 'package:mobile/features/addons/ico/data/datasources/ico_remote_datasource.dart'
    as _i231;
import 'package:mobile/features/addons/ico/data/repositories/ico_repository_impl.dart'
    as _i765;
import 'package:mobile/features/addons/ico/domain/repositories/ico_repository.dart'
    as _i834;
import 'package:mobile/features/addons/ico/domain/usecases/get_featured_ico_offerings_usecase.dart'
    as _i896;
import 'package:mobile/features/addons/ico/domain/usecases/get_ico_blockchains_usecase.dart'
    as _i191;
import 'package:mobile/features/addons/ico/domain/usecases/get_ico_token_types_usecase.dart'
    as _i109;
import 'package:mobile/features/addons/ico/presentation/bloc/ico_bloc.dart'
    as _i800;
import 'package:mobile/features/addons/ico_creator/data/datasources/creator_investor_remote_datasource.dart'
    as _i740;
import 'package:mobile/features/addons/ico_creator/data/datasources/creator_remote_datasource.dart'
    as _i573;
import 'package:mobile/features/addons/ico_creator/data/repositories/creator_investor_repository_impl.dart'
    as _i286;
import 'package:mobile/features/addons/ico_creator/data/repositories/creator_repository_impl.dart'
    as _i233;
import 'package:mobile/features/addons/ico_creator/domain/repositories/creator_investor_repository.dart'
    as _i952;
import 'package:mobile/features/addons/ico_creator/domain/repositories/creator_repository.dart'
    as _i1017;
import 'package:mobile/features/addons/ico_creator/domain/usecases/add_team_member_usecase.dart'
    as _i864;
import 'package:mobile/features/addons/ico_creator/domain/usecases/get_creator_investors_usecase.dart'
    as _i269;
import 'package:mobile/features/addons/ico_creator/domain/usecases/get_creator_performance_usecase.dart'
    as _i410;
import 'package:mobile/features/addons/ico_creator/domain/usecases/get_creator_stats_usecase.dart'
    as _i223;
import 'package:mobile/features/addons/ico_creator/domain/usecases/get_investors_usecase.dart'
    as _i739;
import 'package:mobile/features/addons/ico_creator/domain/usecases/get_launch_plans_usecase.dart'
    as _i1073;
import 'package:mobile/features/addons/ico_creator/domain/usecases/get_team_members_usecase.dart'
    as _i524;
import 'package:mobile/features/addons/ico_creator/domain/usecases/launch_token_usecase.dart'
    as _i779;
import 'package:mobile/features/addons/ico_creator/domain/usecases/update_team_member_usecase.dart'
    as _i904;
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_bloc.dart'
    as _i47;
import 'package:mobile/features/addons/ico_creator/presentation/bloc/creator_investors_bloc.dart'
    as _i542;
import 'package:mobile/features/addons/ico_creator/presentation/bloc/investors_cubit.dart'
    as _i128;
import 'package:mobile/features/addons/ico_creator/presentation/bloc/launch_plan_cubit.dart'
    as _i23;
import 'package:mobile/features/addons/ico_creator/presentation/bloc/performance_cubit.dart'
    as _i811;
import 'package:mobile/features/addons/ico_creator/presentation/bloc/stats_cubit.dart'
    as _i626;
import 'package:mobile/features/addons/mlm/data/datasources/mlm_remote_datasource.dart'
    as _i125;
import 'package:mobile/features/addons/mlm/data/repositories/mlm_repository_impl.dart'
    as _i564;
import 'package:mobile/features/addons/mlm/domain/repositories/mlm_repository.dart'
    as _i955;
import 'package:mobile/features/addons/mlm/domain/usecases/claim_mlm_reward_usecase.dart'
    as _i11;
import 'package:mobile/features/addons/mlm/domain/usecases/get_mlm_conditions_usecase.dart'
    as _i417;
import 'package:mobile/features/addons/mlm/domain/usecases/get_mlm_dashboard_usecase.dart'
    as _i188;
import 'package:mobile/features/addons/mlm/domain/usecases/get_mlm_network_usecase.dart'
    as _i378;
import 'package:mobile/features/addons/mlm/domain/usecases/get_mlm_referrals_usecase.dart'
    as _i92;
import 'package:mobile/features/addons/mlm/domain/usecases/get_mlm_rewards_usecase.dart'
    as _i969;
import 'package:mobile/features/addons/mlm/presentation/bloc/mlm_conditions_bloc.dart'
    as _i1013;
import 'package:mobile/features/addons/mlm/presentation/bloc/mlm_dashboard_bloc.dart'
    as _i880;
import 'package:mobile/features/addons/mlm/presentation/bloc/mlm_network_bloc.dart'
    as _i790;
import 'package:mobile/features/addons/mlm/presentation/bloc/mlm_referrals_bloc.dart'
    as _i47;
import 'package:mobile/features/addons/mlm/presentation/bloc/mlm_rewards_bloc.dart'
    as _i555;
import 'package:mobile/features/addons/p2p/data/datasources/p2p_local_datasource.dart'
    as _i26;
import 'package:mobile/features/addons/p2p/data/datasources/p2p_market_remote_datasource.dart'
    as _i270;
import 'package:mobile/features/addons/p2p/data/datasources/p2p_recommendation_local_datasource.dart'
    as _i816;
import 'package:mobile/features/addons/p2p/data/datasources/p2p_recommendation_remote_datasource.dart'
    as _i679;
import 'package:mobile/features/addons/p2p/data/datasources/p2p_remote_datasource.dart'
    as _i601;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_dashboard_repository_impl.dart'
    as _i976;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_market_repository_impl.dart'
    as _i190;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_matching_repository_impl.dart'
    as _i175;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_offers_repository_impl.dart'
    as _i470;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_payment_methods_repository_impl.dart'
    as _i668;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_recommendation_repository_impl.dart'
    as _i1021;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_reviews_repository_impl.dart'
    as _i406;
import 'package:mobile/features/addons/p2p/data/repositories/p2p_trades_repository_impl.dart'
    as _i608;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_dashboard_repository.dart'
    as _i556;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_market_repository.dart'
    as _i522;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_matching_repository.dart'
    as _i547;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_offers_repository.dart'
    as _i610;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_payment_methods_repository.dart'
    as _i32;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_recommendation_repository.dart'
    as _i810;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_reviews_repository.dart'
    as _i617;
import 'package:mobile/features/addons/p2p/domain/repositories/p2p_trades_repository.dart'
    as _i115;
import 'package:mobile/features/addons/p2p/domain/usecases/create_payment_method_usecase.dart'
    as _i8;
import 'package:mobile/features/addons/p2p/domain/usecases/dashboard/get_dashboard_data_usecase.dart'
    as _i791;
import 'package:mobile/features/addons/p2p/domain/usecases/dashboard/get_dashboard_stats_usecase.dart'
    as _i871;
import 'package:mobile/features/addons/p2p/domain/usecases/dashboard/get_portfolio_data_usecase.dart'
    as _i993;
import 'package:mobile/features/addons/p2p/domain/usecases/dashboard/get_trading_activity_usecase.dart'
    as _i609;
import 'package:mobile/features/addons/p2p/domain/usecases/get_payment_methods_usecase.dart'
    as _i320;
import 'package:mobile/features/addons/p2p/domain/usecases/market/get_market_highlights_usecase.dart'
    as _i914;
import 'package:mobile/features/addons/p2p/domain/usecases/market/get_market_stats_usecase.dart'
    as _i444;
import 'package:mobile/features/addons/p2p/domain/usecases/market/get_p2p_market_highlights_usecase.dart'
    as _i706;
import 'package:mobile/features/addons/p2p/domain/usecases/market/get_p2p_market_stats_usecase.dart'
    as _i278;
import 'package:mobile/features/addons/p2p/domain/usecases/market/get_p2p_top_cryptos_usecase.dart'
    as _i131;
import 'package:mobile/features/addons/p2p/domain/usecases/market/get_top_currencies_usecase.dart'
    as _i864;
import 'package:mobile/features/addons/p2p/domain/usecases/matching/compare_prices_usecase.dart'
    as _i1069;
import 'package:mobile/features/addons/p2p/domain/usecases/matching/guided_matching_usecase.dart'
    as _i870;
import 'package:mobile/features/addons/p2p/domain/usecases/offers/create_offer_usecase.dart'
    as _i283;
import 'package:mobile/features/addons/p2p/domain/usecases/offers/delete_offer_usecase.dart'
    as _i812;
import 'package:mobile/features/addons/p2p/domain/usecases/offers/get_offer_by_id_usecase.dart'
    as _i406;
import 'package:mobile/features/addons/p2p/domain/usecases/offers/get_offers_usecase.dart'
    as _i993;
import 'package:mobile/features/addons/p2p/domain/usecases/offers/get_popular_offers_usecase.dart'
    as _i695;
import 'package:mobile/features/addons/p2p/domain/usecases/offers/update_offer_usecase.dart'
    as _i1067;
import 'package:mobile/features/addons/p2p/domain/usecases/payment_methods/create_payment_method_usecase.dart'
    as _i339;
import 'package:mobile/features/addons/p2p/domain/usecases/payment_methods/delete_payment_method_usecase.dart'
    as _i200;
import 'package:mobile/features/addons/p2p/domain/usecases/payment_methods/update_payment_method_usecase.dart'
    as _i350;
import 'package:mobile/features/addons/p2p/domain/usecases/recommendations/create_price_alert_usecase.dart'
    as _i317;
import 'package:mobile/features/addons/p2p/domain/usecases/recommendations/get_recommendations_usecase.dart'
    as _i298;
import 'package:mobile/features/addons/p2p/domain/usecases/recommendations/manage_recommendations_usecase.dart'
    as _i293;
import 'package:mobile/features/addons/p2p/domain/usecases/reviews/get_reviews_usecase.dart'
    as _i610;
import 'package:mobile/features/addons/p2p/domain/usecases/reviews/get_user_reviews_usecase.dart'
    as _i907;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/cancel_trade_usecase.dart'
    as _i362;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/confirm_trade_usecase.dart'
    as _i0;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/dispute_trade_usecase.dart'
    as _i975;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/get_trade_by_id_usecase.dart'
    as _i526;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/get_trade_messages_usecase.dart'
    as _i467;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/get_trades_usecase.dart'
    as _i914;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/initiate_trade_usecase.dart'
    as _i739;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/release_escrow_usecase.dart'
    as _i624;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/review_trade_usecase.dart'
    as _i868;
import 'package:mobile/features/addons/p2p/domain/usecases/trades/send_trade_message_usecase.dart'
    as _i596;
import 'package:mobile/features/addons/p2p/presentation/bloc/market/market_bloc.dart'
    as _i741;
import 'package:mobile/features/addons/p2p/presentation/bloc/matching/guided_matching_bloc.dart'
    as _i833;
import 'package:mobile/features/addons/p2p/presentation/bloc/offers/create_offer_bloc.dart'
    as _i823;
import 'package:mobile/features/addons/p2p/presentation/bloc/offers/offer_detail_bloc.dart'
    as _i15;
import 'package:mobile/features/addons/p2p/presentation/bloc/offers/offers_bloc.dart'
    as _i832;
import 'package:mobile/features/addons/p2p/presentation/bloc/payment_methods/payment_methods_bloc.dart'
    as _i1027;
import 'package:mobile/features/addons/p2p/presentation/bloc/recommendations/p2p_recommendations_bloc.dart'
    as _i495;
import 'package:mobile/features/addons/p2p/presentation/bloc/trades/trade_chat_bloc.dart'
    as _i601;
import 'package:mobile/features/addons/p2p/presentation/bloc/trades/trade_detail_bloc.dart'
    as _i743;
import 'package:mobile/features/addons/p2p/presentation/bloc/trades/trade_execution_bloc.dart'
    as _i578;
import 'package:mobile/features/addons/p2p/presentation/bloc/trades/trades_bloc.dart'
    as _i347;
import 'package:mobile/features/addons/p2p/presentation/bloc/user_profile/user_profile_bloc.dart'
    as _i529;
import 'package:mobile/features/addons/staking/data/datasources/staking_remote_data_source.dart'
    as _i572;
import 'package:mobile/features/addons/staking/data/repositories/staking_repository_impl.dart'
    as _i1039;
import 'package:mobile/features/addons/staking/domain/repositories/staking_repository.dart'
    as _i959;
import 'package:mobile/features/addons/staking/domain/usecases/claim_rewards_usecase.dart'
    as _i96;
import 'package:mobile/features/addons/staking/domain/usecases/get_pool_analytics_usecase.dart'
    as _i552;
import 'package:mobile/features/addons/staking/domain/usecases/get_staking_pools_usecase.dart'
    as _i534;
import 'package:mobile/features/addons/staking/domain/usecases/get_staking_stats_usecase.dart'
    as _i645;
import 'package:mobile/features/addons/staking/domain/usecases/get_user_positions_usecase.dart'
    as _i1066;
import 'package:mobile/features/addons/staking/domain/usecases/stake_usecase.dart'
    as _i701;
import 'package:mobile/features/addons/staking/domain/usecases/withdraw_usecase.dart'
    as _i856;
import 'package:mobile/features/addons/staking/presentation/bloc/pool_analytics_bloc.dart'
    as _i558;
import 'package:mobile/features/addons/staking/presentation/bloc/position_bloc.dart'
    as _i885;
import 'package:mobile/features/addons/staking/presentation/bloc/staking_bloc.dart'
    as _i792;
import 'package:mobile/features/addons/staking/presentation/bloc/stats_bloc.dart'
    as _i359;
import 'package:mobile/features/auth/domain/usecases/get_cached_user_usecase.dart'
    as _i175;
import 'package:mobile/features/auth/presentation/bloc/auth_bloc.dart' as _i520;
import 'package:mobile/features/chart/data/datasources/chart_remote_datasource.dart'
    as _i872;
import 'package:mobile/features/chart/data/repositories/chart_repository_impl.dart'
    as _i582;
import 'package:mobile/features/chart/domain/repositories/chart_repository.dart'
    as _i10;
import 'package:mobile/features/chart/domain/usecases/get_chart_history_usecase.dart'
    as _i408;
import 'package:mobile/features/chart/domain/usecases/get_chart_with_volume_usecase.dart'
    as _i250;
import 'package:mobile/features/chart/domain/usecases/get_realtime_ticker_usecase.dart'
    as _i217;
import 'package:mobile/features/chart/domain/usecases/get_recent_trades_usecase.dart'
    as _i900;
import 'package:mobile/features/chart/domain/usecases/manage_fullscreen_state_usecase.dart'
    as _i1051;
import 'package:mobile/features/chart/presentation/bloc/chart_bloc.dart'
    as _i627;
import 'package:mobile/features/chart/presentation/bloc/fullscreen_bloc.dart'
    as _i815;
import 'package:mobile/features/dashboard/presentation/bloc/dashboard_bloc.dart'
    as _i354;
import 'package:mobile/features/futures/data/datasources/futures_chart_remote_datasource.dart'
    as _i937;
import 'package:mobile/features/futures/data/datasources/futures_market_remote_datasource.dart'
    as _i970;
import 'package:mobile/features/futures/data/datasources/futures_order_remote_datasource.dart'
    as _i7;
import 'package:mobile/features/futures/data/datasources/futures_position_remote_datasource.dart'
    as _i149;
import 'package:mobile/features/futures/data/repositories/futures_market_repository_impl.dart'
    as _i462;
import 'package:mobile/features/futures/data/repositories/futures_order_repository_impl.dart'
    as _i194;
import 'package:mobile/features/futures/data/repositories/futures_position_repository_impl.dart'
    as _i840;
import 'package:mobile/features/futures/domain/repositories/futures_market_repository.dart'
    as _i400;
import 'package:mobile/features/futures/domain/repositories/futures_order_repository.dart'
    as _i764;
import 'package:mobile/features/futures/domain/repositories/futures_position_repository.dart'
    as _i518;
import 'package:mobile/features/futures/domain/usecases/cancel_futures_order_usecase.dart'
    as _i992;
import 'package:mobile/features/futures/domain/usecases/change_leverage_usecase.dart'
    as _i658;
import 'package:mobile/features/futures/domain/usecases/close_position_usecase.dart'
    as _i88;
import 'package:mobile/features/futures/domain/usecases/get_futures_markets_usecase.dart'
    as _i860;
import 'package:mobile/features/futures/domain/usecases/get_futures_orders_usecase.dart'
    as _i920;
import 'package:mobile/features/futures/domain/usecases/get_futures_positions_usecase.dart'
    as _i965;
import 'package:mobile/features/futures/domain/usecases/place_futures_order_usecase.dart'
    as _i888;
import 'package:mobile/features/futures/presentation/bloc/futures_chart_bloc.dart'
    as _i709;
import 'package:mobile/features/futures/presentation/bloc/futures_form_bloc.dart'
    as _i111;
import 'package:mobile/features/futures/presentation/bloc/futures_header_bloc.dart'
    as _i1051;
import 'package:mobile/features/futures/presentation/bloc/futures_orderbook_bloc.dart'
    as _i925;
import 'package:mobile/features/futures/presentation/bloc/futures_orders_bloc.dart'
    as _i406;
import 'package:mobile/features/futures/presentation/bloc/futures_positions_bloc.dart'
    as _i978;
import 'package:mobile/features/history/data/datasources/transaction_remote_datasource.dart'
    as _i1064;
import 'package:mobile/features/history/data/repositories/transaction_repository_impl.dart'
    as _i964;
import 'package:mobile/features/history/domain/repositories/transaction_repository.dart'
    as _i1030;
import 'package:mobile/features/history/domain/usecases/get_transaction_details_usecase.dart'
    as _i878;
import 'package:mobile/features/history/domain/usecases/get_transactions_usecase.dart'
    as _i151;
import 'package:mobile/features/history/domain/usecases/search_transactions_usecase.dart'
    as _i297;
import 'package:mobile/features/history/presentation/bloc/transaction_bloc.dart'
    as _i554;
import 'package:mobile/features/kyc/data/datasources/kyc_remote_datasource.dart'
    as _i753;
import 'package:mobile/features/kyc/data/repositories/kyc_repository_impl.dart'
    as _i991;
import 'package:mobile/features/kyc/domain/repositories/kyc_repository.dart'
    as _i717;
import 'package:mobile/features/kyc/domain/usecases/get_kyc_applications_usecase.dart'
    as _i246;
import 'package:mobile/features/kyc/domain/usecases/get_kyc_level_by_id_usecase.dart'
    as _i452;
import 'package:mobile/features/kyc/domain/usecases/get_kyc_levels_usecase.dart'
    as _i540;
import 'package:mobile/features/kyc/domain/usecases/submit_kyc_application_usecase.dart'
    as _i811;
import 'package:mobile/features/kyc/domain/usecases/update_kyc_application_usecase.dart'
    as _i711;
import 'package:mobile/features/kyc/domain/usecases/upload_kyc_document_usecase.dart'
    as _i448;
import 'package:mobile/features/kyc/presentation/bloc/kyc_bloc.dart' as _i624;
import 'package:mobile/features/legal/data/datasources/legal_remote_datasource.dart'
    as _i408;
import 'package:mobile/features/legal/data/repositories/legal_repository_impl.dart'
    as _i85;
import 'package:mobile/features/legal/domain/repositories/legal_repository.dart'
    as _i751;
import 'package:mobile/features/market/data/datasources/market_realtime_datasource.dart'
    as _i505;
import 'package:mobile/features/market/data/datasources/market_remote_data_source.dart'
    as _i54;
import 'package:mobile/features/market/data/datasources/market_remote_data_source_impl.dart'
    as _i944;
import 'package:mobile/features/market/data/repositories/market_repository_impl.dart'
    as _i717;
import 'package:mobile/features/market/domain/repositories/market_repository.dart'
    as _i792;
import 'package:mobile/features/market/domain/usecases/get_markets_usecase.dart'
    as _i1067;
import 'package:mobile/features/market/domain/usecases/get_realtime_markets_usecase.dart'
    as _i670;
import 'package:mobile/features/market/presentation/bloc/market_bloc.dart'
    as _i74;
import 'package:mobile/features/news/data/datasources/news_local_datasource.dart'
    as _i873;
import 'package:mobile/features/news/data/datasources/news_remote_datasource.dart'
    as _i64;
import 'package:mobile/features/news/data/repositories/news_repository_impl.dart'
    as _i1053;
import 'package:mobile/features/news/domain/repositories/news_repository.dart'
    as _i506;
import 'package:mobile/features/news/domain/usecases/get_latest_news_usecase.dart'
    as _i1048;
import 'package:mobile/features/news/domain/usecases/get_news_categories_usecase.dart'
    as _i547;
import 'package:mobile/features/news/domain/usecases/get_trending_news_usecase.dart'
    as _i868;
import 'package:mobile/features/news/domain/usecases/search_news_usecase.dart'
    as _i990;
import 'package:mobile/features/news/presentation/bloc/news_bloc.dart' as _i732;
import 'package:mobile/features/notification/data/datasources/notification_remote_data_source.dart'
    as _i251;
import 'package:mobile/features/notification/data/datasources/notification_websocket_data_source.dart'
    as _i499;
import 'package:mobile/features/notification/data/repositories/notification_repository_impl.dart'
    as _i883;
import 'package:mobile/features/notification/domain/repositories/notification_repository.dart'
    as _i612;
import 'package:mobile/features/notification/domain/usecases/connect_websocket_usecase.dart'
    as _i74;
import 'package:mobile/features/notification/domain/usecases/delete_notification_usecase.dart'
    as _i725;
import 'package:mobile/features/notification/domain/usecases/get_notifications_usecase.dart'
    as _i560;
import 'package:mobile/features/notification/domain/usecases/mark_all_notifications_read_usecase.dart'
    as _i192;
import 'package:mobile/features/notification/domain/usecases/mark_notification_read_usecase.dart'
    as _i534;
import 'package:mobile/features/notification/presentation/bloc/notification_bloc.dart'
    as _i158;
import 'package:mobile/features/profile/data/services/profile_service.dart'
    as _i13;
import 'package:mobile/features/profile/domain/repositories/profile_repository.dart'
    as _i728;
import 'package:mobile/features/profile/domain/usecases/generate_two_factor_secret_usecase.dart'
    as _i561;
import 'package:mobile/features/profile/domain/usecases/get_kyc_status_usecase.dart'
    as _i514;
import 'package:mobile/features/profile/domain/usecases/save_two_factor_setup_usecase.dart'
    as _i728;
import 'package:mobile/features/profile/domain/usecases/update_notification_settings_usecase.dart'
    as _i757;
import 'package:mobile/features/profile/domain/usecases/verify_two_factor_setup_usecase.dart'
    as _i244;
import 'package:mobile/features/profile/presentation/bloc/notification_settings_cubit.dart'
    as _i433;
import 'package:mobile/features/profile/presentation/bloc/two_factor_setup_bloc.dart'
    as _i1008;
import 'package:mobile/features/settings/data/datasources/settings_local_datasource.dart'
    as _i602;
import 'package:mobile/features/settings/data/datasources/settings_remote_datasource.dart'
    as _i902;
import 'package:mobile/features/settings/data/repositories/settings_repository_impl.dart'
    as _i948;
import 'package:mobile/features/settings/data/services/settings_service.dart'
    as _i454;
import 'package:mobile/features/settings/domain/repositories/settings_repository.dart'
    as _i360;
import 'package:mobile/features/settings/domain/usecases/get_settings_usecase.dart'
    as _i452;
import 'package:mobile/features/settings/domain/usecases/update_settings_usecase.dart'
    as _i632;
import 'package:mobile/features/settings/presentation/bloc/settings_bloc.dart'
    as _i293;
import 'package:mobile/features/support/data/datasources/support_remote_datasource.dart'
    as _i513;
import 'package:mobile/features/support/data/datasources/support_websocket_datasource.dart'
    as _i56;
import 'package:mobile/features/support/data/repositories/support_repository_impl.dart'
    as _i672;
import 'package:mobile/features/support/domain/repositories/support_repository.dart'
    as _i293;
import 'package:mobile/features/support/domain/usecases/create_support_ticket_usecase.dart'
    as _i725;
import 'package:mobile/features/support/domain/usecases/get_support_tickets_usecase.dart'
    as _i776;
import 'package:mobile/features/support/domain/usecases/live_chat_usecase.dart'
    as _i715;
import 'package:mobile/features/support/domain/usecases/reply_to_ticket_usecase.dart'
    as _i628;
import 'package:mobile/features/support/presentation/bloc/live_chat_bloc.dart'
    as _i430;
import 'package:mobile/features/support/presentation/bloc/support_tickets_bloc.dart'
    as _i849;
import 'package:mobile/features/support/presentation/bloc/ticket_detail_bloc.dart'
    as _i844;
import 'package:mobile/features/theme/data/datasources/theme_local_datasource.dart'
    as _i148;
import 'package:mobile/features/theme/data/repositories/theme_repository_impl.dart'
    as _i272;
import 'package:mobile/features/theme/domain/repositories/theme_repository.dart'
    as _i574;
import 'package:mobile/features/theme/domain/usecases/get_saved_theme_usecase.dart'
    as _i61;
import 'package:mobile/features/theme/domain/usecases/get_system_theme_usecase.dart'
    as _i223;
import 'package:mobile/features/theme/domain/usecases/save_theme_usecase.dart'
    as _i2;
import 'package:mobile/features/theme/presentation/bloc/theme_bloc.dart'
    as _i950;
import 'package:mobile/features/trade/data/datasources/ai_investment_remote_datasource.dart'
    as _i529;
import 'package:mobile/features/trade/data/datasources/order_remote_datasource.dart'
    as _i796;
import 'package:mobile/features/trade/data/repositories/ai_investment_repository_impl.dart'
    as _i331;
import 'package:mobile/features/trade/data/repositories/order_repository_impl.dart'
    as _i760;
import 'package:mobile/features/trade/domain/repositories/ai_investment_repository.dart'
    as _i667;
import 'package:mobile/features/trade/domain/repositories/order_repository.dart'
    as _i669;
import 'package:mobile/features/trade/domain/usecases/connect_trading_websocket_usecase.dart'
    as _i546;
import 'package:mobile/features/trade/domain/usecases/create_ai_investment_usecase.dart'
    as _i557;
import 'package:mobile/features/trade/domain/usecases/get_ai_investment_plans_usecase.dart'
    as _i491;
import 'package:mobile/features/trade/domain/usecases/get_open_orders_usecase.dart'
    as _i989;
import 'package:mobile/features/trade/domain/usecases/get_order_history_usecase.dart'
    as _i244;
import 'package:mobile/features/trade/domain/usecases/get_realtime_orderbook_usecase.dart'
    as _i620;
import 'package:mobile/features/trade/domain/usecases/get_trading_chart_history_usecase.dart'
    as _i270;
import 'package:mobile/features/trade/domain/usecases/get_trading_markets_usecase.dart'
    as _i870;
import 'package:mobile/features/trade/domain/usecases/get_user_ai_investments_usecase.dart'
    as _i927;
import 'package:mobile/features/trade/domain/usecases/place_order_usecase.dart'
    as _i293;
import 'package:mobile/features/trade/presentation/bloc/ai_investment_bloc.dart'
    as _i208;
import 'package:mobile/features/trade/presentation/bloc/order_book_bloc.dart'
    as _i495;
import 'package:mobile/features/trade/presentation/bloc/order_tabs_bloc.dart'
    as _i892;
import 'package:mobile/features/trade/presentation/bloc/trading_chart_bloc.dart'
    as _i963;
import 'package:mobile/features/trade/presentation/bloc/trading_form_bloc.dart'
    as _i186;
import 'package:mobile/features/trade/presentation/bloc/trading_header_bloc.dart'
    as _i288;
import 'package:mobile/features/trade/presentation/bloc/trading_pair_selector_bloc.dart'
    as _i574;
import 'package:mobile/features/transfer/data/datasources/transfer_remote_datasource.dart'
    as _i650;
import 'package:mobile/features/transfer/data/datasources/transfer_remote_datasource_impl.dart'
    as _i729;
import 'package:mobile/features/transfer/data/repositories/transfer_repository_impl.dart'
    as _i411;
import 'package:mobile/features/transfer/domain/repositories/transfer_repository.dart'
    as _i692;
import 'package:mobile/features/transfer/domain/usecases/create_transfer_usecase.dart'
    as _i58;
import 'package:mobile/features/transfer/domain/usecases/get_transfer_currencies_usecase.dart'
    as _i942;
import 'package:mobile/features/transfer/domain/usecases/get_transfer_options_usecase.dart'
    as _i767;
import 'package:mobile/features/transfer/domain/usecases/get_wallet_balance_usecase.dart'
    as _i166;
import 'package:mobile/features/transfer/presentation/bloc/transfer_bloc.dart'
    as _i606;
import 'package:mobile/features/wallet/data/datasources/currency_price_remote_datasource.dart'
    as _i776;
import 'package:mobile/features/wallet/data/datasources/deposit_remote_datasource.dart'
    as _i587;
import 'package:mobile/features/wallet/data/datasources/eco_deposit_remote_datasource.dart'
    as _i221;
import 'package:mobile/features/wallet/data/datasources/futures_deposit_remote_datasource.dart'
    as _i717;
import 'package:mobile/features/wallet/data/datasources/futures_deposit_remote_datasource_impl.dart'
    as _i584;
import 'package:mobile/features/wallet/data/datasources/spot_deposit_remote_datasource.dart'
    as _i705;
import 'package:mobile/features/wallet/data/datasources/wallet_cache_datasource.dart'
    as _i10;
import 'package:mobile/features/wallet/data/datasources/wallet_remote_datasource.dart'
    as _i823;
import 'package:mobile/features/wallet/data/repositories/currency_price_repository_impl.dart'
    as _i255;
import 'package:mobile/features/wallet/data/repositories/deposit_repository_impl.dart'
    as _i598;
import 'package:mobile/features/wallet/data/repositories/eco_deposit_repository_impl.dart'
    as _i1033;
import 'package:mobile/features/wallet/data/repositories/futures_deposit_repository_impl.dart'
    as _i364;
import 'package:mobile/features/wallet/data/repositories/spot_deposit_repository_impl.dart'
    as _i995;
import 'package:mobile/features/wallet/data/repositories/wallet_repository_impl.dart'
    as _i657;
import 'package:mobile/features/wallet/domain/repositories/currency_price_repository.dart'
    as _i104;
import 'package:mobile/features/wallet/domain/repositories/deposit_repository.dart'
    as _i596;
import 'package:mobile/features/wallet/domain/repositories/eco_deposit_repository.dart'
    as _i362;
import 'package:mobile/features/wallet/domain/repositories/futures_deposit_repository.dart'
    as _i257;
import 'package:mobile/features/wallet/domain/repositories/spot_deposit_repository.dart'
    as _i178;
import 'package:mobile/features/wallet/domain/repositories/wallet_repository.dart'
    as _i183;
import 'package:mobile/features/wallet/domain/usecases/create_fiat_deposit_usecase.dart'
    as _i600;
import 'package:mobile/features/wallet/domain/usecases/create_paypal_order_usecase.dart'
    as _i240;
import 'package:mobile/features/wallet/domain/usecases/create_spot_deposit_usecase.dart'
    as _i298;
import 'package:mobile/features/wallet/domain/usecases/create_stripe_payment_intent_usecase.dart'
    as _i902;
import 'package:mobile/features/wallet/domain/usecases/generate_eco_address_usecase.dart'
    as _i948;
import 'package:mobile/features/wallet/domain/usecases/generate_futures_address_usecase.dart'
    as _i716;
import 'package:mobile/features/wallet/domain/usecases/generate_spot_deposit_address_usecase.dart'
    as _i109;
import 'package:mobile/features/wallet/domain/usecases/get_currency_options_usecase.dart'
    as _i798;
import 'package:mobile/features/wallet/domain/usecases/get_currency_price_usecase.dart'
    as _i574;
import 'package:mobile/features/wallet/domain/usecases/get_deposit_methods_usecase.dart'
    as _i707;
import 'package:mobile/features/wallet/domain/usecases/get_eco_currencies_usecase.dart'
    as _i951;
import 'package:mobile/features/wallet/domain/usecases/get_eco_tokens_usecase.dart'
    as _i516;
import 'package:mobile/features/wallet/domain/usecases/get_futures_currencies_usecase.dart'
    as _i467;
import 'package:mobile/features/wallet/domain/usecases/get_futures_tokens_usecase.dart'
    as _i397;
import 'package:mobile/features/wallet/domain/usecases/get_spot_currencies_usecase.dart'
    as _i367;
import 'package:mobile/features/wallet/domain/usecases/get_spot_networks_usecase.dart'
    as _i402;
import 'package:mobile/features/wallet/domain/usecases/get_symbol_balances_usecase.dart'
    as _i402;
import 'package:mobile/features/wallet/domain/usecases/get_wallet_balance_usecase.dart'
    as _i668;
import 'package:mobile/features/wallet/domain/usecases/verify_paypal_payment_usecase.dart'
    as _i881;
import 'package:mobile/features/wallet/domain/usecases/verify_spot_deposit_usecase.dart'
    as _i358;
import 'package:mobile/features/wallet/domain/usecases/verify_stripe_payment_usecase.dart'
    as _i35;
import 'package:mobile/features/wallet/presentation/bloc/currency_price_bloc.dart'
    as _i558;
import 'package:mobile/features/wallet/presentation/bloc/deposit_bloc.dart'
    as _i413;
import 'package:mobile/features/wallet/presentation/bloc/eco_deposit_bloc.dart'
    as _i233;
import 'package:mobile/features/wallet/presentation/bloc/futures_deposit_bloc.dart'
    as _i7;
import 'package:mobile/features/wallet/presentation/bloc/spot_deposit_bloc.dart'
    as _i1010;
import 'package:mobile/features/withdraw/data/datasources/withdraw_remote_datasource.dart'
    as _i784;
import 'package:mobile/features/withdraw/data/datasources/withdraw_remote_datasource_impl.dart'
    as _i202;
import 'package:mobile/features/withdraw/data/repositories/withdraw_repository_impl.dart'
    as _i401;
import 'package:mobile/features/withdraw/domain/repositories/withdraw_repository.dart'
    as _i84;
import 'package:mobile/features/withdraw/domain/usecases/get_withdraw_currencies_usecase.dart'
    as _i550;
import 'package:mobile/features/withdraw/domain/usecases/get_withdraw_methods_usecase.dart'
    as _i1071;
import 'package:mobile/features/withdraw/domain/usecases/submit_withdraw_usecase.dart'
    as _i433;
import 'package:mobile/features/withdraw/presentation/bloc/withdraw_bloc.dart'
    as _i277;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i848.NotificationService>(() => _i848.NotificationService());
    gh.factory<_i542.ScreenshotService>(() => _i542.ScreenshotService());
    gh.factory<_i1051.ManageFullscreenStateUseCase>(
        () => const _i1051.ManageFullscreenStateUseCase());
    gh.factory<_i900.GetRecentTradesUseCase>(
        () => const _i900.GetRecentTradesUseCase());
    gh.factory<_i363.AddReviewCubit>(() => _i363.AddReviewCubit());
    gh.singleton<_i882.StripeService>(() => _i882.StripeService());
    gh.singleton<_i1.MaintenanceService>(() => _i1.MaintenanceService());
    gh.singleton<_i244.FuturesWebSocketService>(
      () => _i244.FuturesWebSocketService(),
      dispose: (i) => i.dispose(),
    );
    gh.singleton<_i458.TradingWebSocketService>(
        () => _i458.TradingWebSocketService());
    gh.singleton<_i903.MarketService>(() => _i903.MarketService());
    gh.singleton<_i794.PriceAnimationService>(
        () => _i794.PriceAnimationService());
    gh.lazySingleton<_i16.NavigationService>(() => _i16.NavigationService());
    gh.factory<_i270.P2PMarketRemoteDataSource>(
        () => _i270.P2PMarketRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i970.FuturesMarketRemoteDataSource>(
        () => _i970.FuturesMarketRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i1064.TransactionRemoteDataSource>(
        () => _i1064.TransactionRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i902.SettingsRemoteDataSource>(
        () => _i902.SettingsRemoteDataSource(gh<_i456.ApiClient>()));
    gh.factory<_i740.CreatorInvestorRemoteDataSource>(
        () => _i740.CreatorInvestorRemoteDataSource(gh<_i456.ApiClient>()));
    gh.factory<_i271.FavoritesService>(
        () => _i271.FavoritesService(gh<_i460.SharedPreferences>()));
    gh.factory<_i602.SettingsLocalDataSource>(
        () => _i602.SettingsLocalDataSource(gh<_i460.SharedPreferences>()));
    gh.factory<_i481.WishlistBloc>(
        () => _i481.WishlistBloc(gh<_i460.SharedPreferences>()));
    gh.factory<_i497.BlogRemoteDataSource>(
        () => _i497.BlogRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.factory<_i514.GetKycStatusUseCase>(
        () => _i514.GetKycStatusUseCase(gh<_i13.ProfileService>()));
    gh.factory<_i64.NewsRemoteDataSource>(
        () => _i64.NewsRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i925.FuturesOrderBookBloc>(
        () => _i925.FuturesOrderBookBloc(gh<_i244.FuturesWebSocketService>()));
    gh.factory<_i125.MlmRemoteDataSource>(
        () => _i125.MlmRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i873.NewsLocalDataSource>(
        () => _i873.NewsLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.factory<_i757.UpdateNotificationSettingsUseCase>(() =>
        _i757.UpdateNotificationSettingsUseCase(gh<_i728.ProfileRepository>()));
    gh.factory<_i815.FullscreenBloc>(
        () => _i815.FullscreenBloc(gh<_i1051.ManageFullscreenStateUseCase>()));
    gh.factory<_i499.NotificationWebSocketDataSource>(
        () => _i499.NotificationWebSocketDataSourceImpl());
    gh.factory<_i449.DiscountRemoteDataSource>(
        () => _i449.DiscountRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i26.P2PLocalDataSource>(
        () => _i26.P2PLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.factory<_i821.NetworkInfo>(() => _i821.NetworkInfoImpl());
    gh.factory<_i937.FuturesChartRemoteDataSource>(
        () => _i937.FuturesChartRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i601.P2PRemoteDataSource>(
        () => _i601.P2PRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i610.P2POffersRepository>(() => _i470.P2POffersRepositoryImpl(
          gh<_i601.P2PRemoteDataSource>(),
          gh<_i26.P2PLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i872.ChartRemoteDataSource>(
        () => _i872.ChartRemoteDataSourceImpl(gh<_i361.Dio>()));
    gh.factory<_i952.CreatorInvestorRepository>(
        () => _i286.CreatorInvestorRepositoryImpl(
              gh<_i740.CreatorInvestorRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i56.SupportWebSocketDataSource>(
        () => _i56.SupportWebSocketDataSourceImpl());
    gh.factory<_i529.AiInvestmentRemoteDataSource>(
        () => _i529.AiInvestmentRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i10.ChartRepository>(() => _i582.ChartRepositoryImpl(
          gh<_i872.ChartRemoteDataSource>(),
          gh<_i458.TradingWebSocketService>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i955.MlmRepository>(() => _i564.MlmRepositoryImpl(
          gh<_i125.MlmRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i10.WalletCacheDataSource>(
        () => _i10.WalletCacheDataSource(gh<_i558.FlutterSecureStorage>()));
    gh.singleton<_i873.DioClient>(() => _i873.DioClient(
          gh<_i361.Dio>(),
          secureStorage: gh<_i558.FlutterSecureStorage>(),
          preferences: gh<_i460.SharedPreferences>(),
        ));
    gh.factory<_i702.EcommerceRemoteDataSource>(
        () => _i702.EcommerceRemoteDataSourceImpl(gh<_i456.ApiClient>()));
    gh.factory<_i962.AuthorsBloc>(
        () => _i962.AuthorsBloc(gh<_i497.BlogRemoteDataSource>()));
    gh.singleton<_i881.ChartService>(
        () => _i881.ChartService(gh<_i903.MarketService>()));
    gh.lazySingleton<_i314.WebSocketService>(
        () => _i314.WebSocketService(gh<_i903.MarketService>()));
    gh.factory<_i148.ThemeLocalDataSource>(
        () => _i148.ThemeLocalDataSourceImpl(gh<_i460.SharedPreferences>()));
    gh.factory<_i115.P2PTradesRepository>(() => _i608.P2PTradesRepositoryImpl(
          gh<_i601.P2PRemoteDataSource>(),
          gh<_i26.P2PLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i546.ConnectTradingWebSocketUseCase>(() =>
        _i546.ConnectTradingWebSocketUseCase(
            gh<_i458.TradingWebSocketService>()));
    gh.factory<_i620.GetRealtimeOrderbookUseCase>(() =>
        _i620.GetRealtimeOrderbookUseCase(gh<_i458.TradingWebSocketService>()));
    gh.factory<_i217.GetRealtimeTickerUseCase>(() =>
        _i217.GetRealtimeTickerUseCase(gh<_i458.TradingWebSocketService>()));
    gh.factory<_i728.SaveTwoFactorSetupUseCase>(
        () => _i728.SaveTwoFactorSetupUseCase(gh<_i728.ProfileRepository>()));
    gh.factory<_i561.GenerateTwoFactorSecretUseCase>(() =>
        _i561.GenerateTwoFactorSecretUseCase(gh<_i728.ProfileRepository>()));
    gh.factory<_i244.VerifyTwoFactorSetupUseCase>(
        () => _i244.VerifyTwoFactorSetupUseCase(gh<_i728.ProfileRepository>()));
    gh.factory<_i1030.TransactionRepository>(() =>
        _i964.TransactionRepositoryImpl(
            gh<_i1064.TransactionRemoteDataSource>()));
    gh.factory<_i796.OrderRemoteDataSource>(
        () => _i796.OrderRemoteDataSource(gh<_i873.DioClient>()));
    gh.factory<_i572.StakingRemoteDataSource>(
        () => _i572.StakingRemoteDataSource(gh<_i873.DioClient>()));
    gh.factory<_i823.WalletRemoteDataSource>(
        () => _i823.WalletRemoteDataSource(gh<_i873.DioClient>()));
    gh.factory<_i522.P2PMarketRepository>(() => _i190.P2PMarketRepositoryImpl(
          gh<_i601.P2PRemoteDataSource>(),
          gh<_i26.P2PLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
          gh<_i270.P2PMarketRemoteDataSource>(),
        ));
    gh.factory<_i251.NotificationRemoteDataSource>(
        () => _i251.NotificationRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i705.SpotDepositRemoteDataSource>(
        () => _i705.SpotDepositRemoteDataSourceImpl(
              gh<_i873.DioClient>(),
              gh<_i558.FlutterSecureStorage>(),
              gh<_i175.GetCachedUserUseCase>(),
            ));
    gh.factory<_i408.LegalRemoteDataSource>(
        () => _i408.LegalRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i506.NewsRepository>(() => _i1053.NewsRepositoryImpl(
          gh<_i64.NewsRemoteDataSource>(),
          gh<_i873.NewsLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i753.KycRemoteDataSource>(
        () => _i753.KycRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i959.StakingRepository>(() =>
        _i1039.StakingRepositoryImpl(gh<_i572.StakingRemoteDataSource>()));
    gh.factory<_i269.GetCreatorInvestorsUseCase>(() =>
        _i269.GetCreatorInvestorsUseCase(
            gh<_i952.CreatorInvestorRepository>()));
    gh.factory<_i202.EcommerceRemoteDataSource>(
        () => _i202.EcommerceRemoteDataSourceImpl(client: gh<_i519.Client>()));
    gh.factory<_i7.FuturesOrderRemoteDataSource>(
        () => _i7.FuturesOrderRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i433.NotificationSettingsCubit>(
        () => _i433.NotificationSettingsCubit(
              gh<_i757.UpdateNotificationSettingsUseCase>(),
              gh<_i13.ProfileService>(),
            ));
    gh.factory<_i231.IcoRemoteDataSource>(
        () => _i231.IcoRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i400.FuturesMarketRepository>(
        () => _i462.FuturesMarketRepositoryImpl(
              gh<_i970.FuturesMarketRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i776.CurrencyPriceRemoteDataSource>(
        () => _i776.CurrencyPriceRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i914.GetMarketHighlightsUseCase>(() =>
        _i914.GetMarketHighlightsUseCase(gh<_i522.P2PMarketRepository>()));
    gh.factory<_i706.GetP2PMarketHighlightsUseCase>(() =>
        _i706.GetP2PMarketHighlightsUseCase(gh<_i522.P2PMarketRepository>()));
    gh.factory<_i278.GetP2PMarketStatsUseCase>(
        () => _i278.GetP2PMarketStatsUseCase(gh<_i522.P2PMarketRepository>()));
    gh.factory<_i444.GetMarketStatsUseCase>(
        () => _i444.GetMarketStatsUseCase(gh<_i522.P2PMarketRepository>()));
    gh.factory<_i864.GetTopCurrenciesUseCase>(
        () => _i864.GetTopCurrenciesUseCase(gh<_i522.P2PMarketRepository>()));
    gh.factory<_i131.GetP2PTopCryptosUseCase>(
        () => _i131.GetP2PTopCryptosUseCase(gh<_i522.P2PMarketRepository>()));
    gh.factory<_i784.WithdrawRemoteDataSource>(
        () => _i202.WithdrawRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i650.TransferRemoteDataSource>(
        () => _i729.TransferRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i222.DiscountRepository>(() =>
        _i681.DiscountRepositoryImpl(gh<_i449.DiscountRemoteDataSource>()));
    gh.factory<_i816.P2PRecommendationLocalDataSource>(() =>
        _i816.P2PRecommendationLocalDataSource(gh<_i460.SharedPreferences>()));
    gh.factory<_i587.DepositRemoteDataSource>(
        () => _i587.DepositRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i149.FuturesPositionRemoteDataSource>(
        () => _i149.FuturesPositionRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i834.IcoRepository>(() => _i765.IcoRepositoryImpl(
          gh<_i231.IcoRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i1031.EcommerceLocalDataSource>(() =>
        _i1031.EcommerceLocalDataSourceImpl(
            sharedPreferences: gh<_i460.SharedPreferences>()));
    gh.factory<_i406.GetOfferByIdUseCase>(
        () => _i406.GetOfferByIdUseCase(gh<_i610.P2POffersRepository>()));
    gh.factory<_i1067.UpdateOfferUseCase>(
        () => _i1067.UpdateOfferUseCase(gh<_i610.P2POffersRepository>()));
    gh.factory<_i695.GetPopularOffersUseCase>(
        () => _i695.GetPopularOffersUseCase(gh<_i610.P2POffersRepository>()));
    gh.factory<_i812.DeleteOfferUseCase>(
        () => _i812.DeleteOfferUseCase(gh<_i610.P2POffersRepository>()));
    gh.factory<_i283.CreateOfferUseCase>(
        () => _i283.CreateOfferUseCase(gh<_i610.P2POffersRepository>()));
    gh.factory<_i993.GetOffersUseCase>(
        () => _i993.GetOffersUseCase(gh<_i610.P2POffersRepository>()));
    gh.factory<_i92.GetMlmReferralsUseCase>(
        () => _i92.GetMlmReferralsUseCase(gh<_i955.MlmRepository>()));
    gh.factory<_i417.GetMlmConditionsUseCase>(
        () => _i417.GetMlmConditionsUseCase(gh<_i955.MlmRepository>()));
    gh.factory<_i969.GetMlmRewardsUseCase>(
        () => _i969.GetMlmRewardsUseCase(gh<_i955.MlmRepository>()));
    gh.factory<_i188.GetMlmDashboardUseCase>(
        () => _i188.GetMlmDashboardUseCase(gh<_i955.MlmRepository>()));
    gh.factory<_i378.GetMlmNetworkUseCase>(
        () => _i378.GetMlmNetworkUseCase(gh<_i955.MlmRepository>()));
    gh.factory<_i11.ClaimMlmRewardUseCase>(
        () => _i11.ClaimMlmRewardUseCase(gh<_i955.MlmRepository>()));
    gh.factory<_i96.ClaimRewardsUseCase>(
        () => _i96.ClaimRewardsUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i856.WithdrawUseCase>(
        () => _i856.WithdrawUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i534.GetStakingPoolsUseCase>(
        () => _i534.GetStakingPoolsUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i552.GetPoolAnalyticsUseCase>(
        () => _i552.GetPoolAnalyticsUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i1066.GetUserPositionsUseCase>(
        () => _i1066.GetUserPositionsUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i645.GetStakingStatsUseCase>(
        () => _i645.GetStakingStatsUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i701.StakeUseCase>(
        () => _i701.StakeUseCase(gh<_i959.StakingRepository>()));
    gh.factory<_i54.MarketRemoteDataSource>(
        () => _i944.MarketRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.singleton<_i792.StakingBloc>(
        () => _i792.StakingBloc(gh<_i534.GetStakingPoolsUseCase>()));
    gh.factory<_i679.P2PRecommendationRemoteDataSource>(
        () => _i679.P2PRecommendationRemoteDataSource(gh<_i873.DioClient>()));
    gh.factory<_i741.P2PMarketBloc>(() => _i741.P2PMarketBloc(
          gh<_i278.GetP2PMarketStatsUseCase>(),
          gh<_i706.GetP2PMarketHighlightsUseCase>(),
          gh<_i131.GetP2PTopCryptosUseCase>(),
        ));
    gh.factory<_i47.MlmReferralsBloc>(() => _i47.MlmReferralsBloc(
          gh<_i92.GetMlmReferralsUseCase>(),
          gh<_i955.MlmRepository>(),
        ));
    gh.factory<_i771.BlogAuthorService>(
        () => _i771.BlogAuthorService(gh<_i497.BlogRemoteDataSource>()));
    gh.factory<_i573.CreatorRemoteDataSource>(
        () => _i573.CreatorRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i513.SupportRemoteDataSource>(
        () => _i513.SupportRemoteDataSourceImpl(gh<_i873.DioClient>()));
    gh.factory<_i669.OrderRepository>(() => _i760.OrderRepositoryImpl(
          gh<_i796.OrderRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i555.MlmRewardsBloc>(() => _i555.MlmRewardsBloc(
          gh<_i969.GetMlmRewardsUseCase>(),
          gh<_i11.ClaimMlmRewardUseCase>(),
          gh<_i955.MlmRepository>(),
        ));
    gh.factory<_i542.CreatorInvestorsBloc>(() =>
        _i542.CreatorInvestorsBloc(gh<_i269.GetCreatorInvestorsUseCase>()));
    gh.factory<_i299.BlogBloc>(
        () => _i299.BlogBloc(gh<_i497.BlogRemoteDataSource>()));
    gh.factory<_i183.WalletRepository>(() => _i657.WalletRepositoryImpl(
          remoteDataSource: gh<_i823.WalletRemoteDataSource>(),
          cacheDataSource: gh<_i10.WalletCacheDataSource>(),
          networkInfo: gh<_i821.NetworkInfo>(),
        ));
    gh.singleton<_i711.GlobalNotificationService>(
      () => _i711.GlobalNotificationService(
        gh<_i499.NotificationWebSocketDataSource>(),
        gh<_i13.ProfileService>(),
      ),
      dispose: (i) => i.dispose(),
    );
    gh.factory<_i360.SettingsRepository>(() => _i948.SettingsRepositoryImpl(
          gh<_i902.SettingsRemoteDataSource>(),
          gh<_i602.SettingsLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i32.P2PPaymentMethodsRepository>(
        () => _i668.P2PPaymentMethodsRepositoryImpl(
              gh<_i601.P2PRemoteDataSource>(),
              gh<_i26.P2PLocalDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i495.OrderBookBloc>(() => _i495.OrderBookBloc(
          gh<_i620.GetRealtimeOrderbookUseCase>(),
          gh<_i458.TradingWebSocketService>(),
        ));
    gh.factory<_i15.OfferDetailBloc>(
        () => _i15.OfferDetailBloc(gh<_i406.GetOfferByIdUseCase>()));
    gh.factory<_i617.P2PReviewsRepository>(() => _i406.P2PReviewsRepositoryImpl(
          gh<_i601.P2PRemoteDataSource>(),
          gh<_i26.P2PLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i717.KycRepository>(
        () => _i991.KycRepositoryImpl(gh<_i753.KycRemoteDataSource>()));
    gh.factory<_i178.SpotDepositRepository>(() =>
        _i995.SpotDepositRepositoryImpl(
            gh<_i705.SpotDepositRemoteDataSource>()));
    gh.factory<_i880.MlmDashboardBloc>(
        () => _i880.MlmDashboardBloc(gh<_i188.GetMlmDashboardUseCase>()));
    gh.factory<_i624.ReleaseEscrowUseCase>(
        () => _i624.ReleaseEscrowUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i914.GetTradesUseCase>(
        () => _i914.GetTradesUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i467.GetTradeMessagesUseCase>(
        () => _i467.GetTradeMessagesUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i0.ConfirmTradeUseCase>(
        () => _i0.ConfirmTradeUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i739.InitiateTradeUseCase>(
        () => _i739.InitiateTradeUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i362.CancelTradeUseCase>(
        () => _i362.CancelTradeUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i526.GetTradeByIdUseCase>(
        () => _i526.GetTradeByIdUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i596.SendTradeMessageUseCase>(
        () => _i596.SendTradeMessageUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i868.ReviewTradeUseCase>(
        () => _i868.ReviewTradeUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i975.DisputeTradeUseCase>(
        () => _i975.DisputeTradeUseCase(gh<_i115.P2PTradesRepository>()));
    gh.factory<_i558.PoolAnalyticsBloc>(
        () => _i558.PoolAnalyticsBloc(gh<_i552.GetPoolAnalyticsUseCase>()));
    gh.factory<_i270.GetTradingChartHistoryUseCase>(
        () => _i270.GetTradingChartHistoryUseCase(gh<_i10.ChartRepository>()));
    gh.factory<_i408.GetChartHistoryUseCase>(
        () => _i408.GetChartHistoryUseCase(gh<_i10.ChartRepository>()));
    gh.factory<_i250.GetChartWithVolumeUseCase>(
        () => _i250.GetChartWithVolumeUseCase(gh<_i10.ChartRepository>()));
    gh.factory<_i505.MarketRealtimeDataSource>(
        () => _i505.MarketRealtimeDataSourceImpl(gh<_i314.WebSocketService>()));
    gh.factory<_i547.P2PMatchingRepository>(
        () => _i175.P2PMatchingRepositoryImpl(
              gh<_i601.P2PRemoteDataSource>(),
              gh<_i26.P2PLocalDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i556.P2PDashboardRepository>(
        () => _i976.P2PDashboardRepositoryImpl(
              gh<_i601.P2PRemoteDataSource>(),
              gh<_i26.P2PLocalDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i601.TradeChatBloc>(() => _i601.TradeChatBloc(
          gh<_i467.GetTradeMessagesUseCase>(),
          gh<_i596.SendTradeMessageUseCase>(),
        ));
    gh.factory<_i547.GetNewsCategoriesUseCase>(
        () => _i547.GetNewsCategoriesUseCase(gh<_i506.NewsRepository>()));
    gh.factory<_i1048.GetLatestNewsUseCase>(
        () => _i1048.GetLatestNewsUseCase(gh<_i506.NewsRepository>()));
    gh.factory<_i990.SearchNewsUseCase>(
        () => _i990.SearchNewsUseCase(gh<_i506.NewsRepository>()));
    gh.factory<_i868.GetTrendingNewsUseCase>(
        () => _i868.GetTrendingNewsUseCase(gh<_i506.NewsRepository>()));
    gh.factory<_i221.EcoDepositRemoteDataSource>(
        () => _i221.EcoDepositRemoteDataSourceImpl(
              gh<_i873.DioClient>(),
              gh<_i175.GetCachedUserUseCase>(),
            ));
    gh.factory<_i402.GetSymbolBalancesUseCase>(
        () => _i402.GetSymbolBalancesUseCase(gh<_i183.WalletRepository>()));
    gh.factory<_i792.MarketRepository>(() => _i717.MarketRepositoryImpl(
          gh<_i54.MarketRemoteDataSource>(),
          gh<_i505.MarketRealtimeDataSource>(),
          gh<_i821.NetworkInfo>(),
          gh<_i881.ChartService>(),
          gh<_i903.MarketService>(),
        ));
    gh.factory<_i717.FuturesDepositRemoteDataSource>(
        () => _i584.FuturesDepositRemoteDataSourceImpl(
              gh<_i221.EcoDepositRemoteDataSource>(),
              gh<_i873.DioClient>(),
            ));
    gh.factory<_i293.SupportRepository>(() => _i672.SupportRepositoryImpl(
          gh<_i513.SupportRemoteDataSource>(),
          gh<_i56.SupportWebSocketDataSource>(),
        ));
    gh.factory<_i104.CurrencyPriceRepository>(() =>
        _i255.CurrencyPriceRepositoryImpl(
            gh<_i776.CurrencyPriceRemoteDataSource>()));
    gh.singleton<_i885.PositionBloc>(() => _i885.PositionBloc(
          gh<_i1066.GetUserPositionsUseCase>(),
          gh<_i856.WithdrawUseCase>(),
          gh<_i96.ClaimRewardsUseCase>(),
        ));
    gh.factory<_i627.ChartBloc>(() => _i627.ChartBloc(
          gh<_i217.GetRealtimeTickerUseCase>(),
          gh<_i408.GetChartHistoryUseCase>(),
          gh<_i250.GetChartWithVolumeUseCase>(),
          gh<_i900.GetRecentTradesUseCase>(),
          gh<_i458.TradingWebSocketService>(),
        ));
    gh.factory<_i1017.CreatorRepository>(() => _i233.CreatorRepositoryImpl(
          gh<_i573.CreatorRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i667.AiInvestmentRepository>(
        () => _i331.AiInvestmentRepositoryImpl(
              gh<_i529.AiInvestmentRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i448.UploadKycDocumentUseCase>(
        () => _i448.UploadKycDocumentUseCase(gh<_i717.KycRepository>()));
    gh.factory<_i811.SubmitKycApplicationUseCase>(
        () => _i811.SubmitKycApplicationUseCase(gh<_i717.KycRepository>()));
    gh.factory<_i540.GetKycLevelsUseCase>(
        () => _i540.GetKycLevelsUseCase(gh<_i717.KycRepository>()));
    gh.factory<_i246.GetKycApplicationsUseCase>(
        () => _i246.GetKycApplicationsUseCase(gh<_i717.KycRepository>()));
    gh.factory<_i711.UpdateKycApplicationUseCase>(
        () => _i711.UpdateKycApplicationUseCase(gh<_i717.KycRepository>()));
    gh.factory<_i452.GetKycLevelByIdUseCase>(
        () => _i452.GetKycLevelByIdUseCase(gh<_i717.KycRepository>()));
    gh.singleton<_i359.StatsBloc>(
        () => _i359.StatsBloc(gh<_i645.GetStakingStatsUseCase>()));
    gh.factory<_i257.FuturesDepositRepository>(
        () => _i364.FuturesDepositRepositoryImpl(
              gh<_i717.FuturesDepositRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i764.FuturesOrderRepository>(
        () => _i194.FuturesOrderRepositoryImpl(
              gh<_i7.FuturesOrderRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i1008.TwoFactorSetupBloc>(() => _i1008.TwoFactorSetupBloc(
          generateSecretUseCase: gh<_i561.GenerateTwoFactorSecretUseCase>(),
          verifySetupUseCase: gh<_i244.VerifyTwoFactorSetupUseCase>(),
          saveSetupUseCase: gh<_i728.SaveTwoFactorSetupUseCase>(),
        ));
    gh.factory<_i574.ThemeRepository>(
        () => _i272.ThemeRepositoryImpl(gh<_i148.ThemeLocalDataSource>()));
    gh.factory<_i151.GetTransactionsUseCase>(
        () => _i151.GetTransactionsUseCase(gh<_i1030.TransactionRepository>()));
    gh.factory<_i878.GetTransactionDetailsUseCase>(() =>
        _i878.GetTransactionDetailsUseCase(gh<_i1030.TransactionRepository>()));
    gh.factory<_i297.SearchTransactionsUseCase>(() =>
        _i297.SearchTransactionsUseCase(gh<_i1030.TransactionRepository>()));
    gh.factory<_i1069.ComparePricesUseCase>(
        () => _i1069.ComparePricesUseCase(gh<_i547.P2PMatchingRepository>()));
    gh.factory<_i870.GuidedMatchingUseCase>(
        () => _i870.GuidedMatchingUseCase(gh<_i547.P2PMatchingRepository>()));
    gh.factory<_i992.CancelFuturesOrderUseCase>(() =>
        _i992.CancelFuturesOrderUseCase(gh<_i764.FuturesOrderRepository>()));
    gh.factory<_i888.PlaceFuturesOrderUseCase>(() =>
        _i888.PlaceFuturesOrderUseCase(gh<_i764.FuturesOrderRepository>()));
    gh.factory<_i920.GetFuturesOrdersUseCase>(() =>
        _i920.GetFuturesOrdersUseCase(gh<_i764.FuturesOrderRepository>()));
    gh.factory<_i751.LegalRepository>(
        () => _i85.LegalRepositoryImpl(gh<_i408.LegalRemoteDataSource>()));
    gh.factory<_i864.AddTeamMemberUseCase>(
        () => _i864.AddTeamMemberUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i904.UpdateTeamMemberUseCase>(
        () => _i904.UpdateTeamMemberUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i410.GetCreatorPerformanceUseCase>(() =>
        _i410.GetCreatorPerformanceUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i84.WithdrawRepository>(() => _i401.WithdrawRepositoryImpl(
          gh<_i784.WithdrawRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i811.PerformanceCubit>(
        () => _i811.PerformanceCubit(gh<_i410.GetCreatorPerformanceUseCase>()));
    gh.factory<_i347.TradesBloc>(
        () => _i347.TradesBloc(gh<_i914.GetTradesUseCase>()));
    gh.factory<_i743.TradeDetailBloc>(() => _i743.TradeDetailBloc(
          gh<_i526.GetTradeByIdUseCase>(),
          gh<_i0.ConfirmTradeUseCase>(),
          gh<_i362.CancelTradeUseCase>(),
          gh<_i624.ReleaseEscrowUseCase>(),
          gh<_i975.DisputeTradeUseCase>(),
          gh<_i868.ReviewTradeUseCase>(),
        ));
    gh.factory<_i790.MlmNetworkBloc>(
        () => _i790.MlmNetworkBloc(gh<_i378.GetMlmNetworkUseCase>()));
    gh.factory<_i406.FuturesOrdersBloc>(() => _i406.FuturesOrdersBloc(
          gh<_i920.GetFuturesOrdersUseCase>(),
          gh<_i992.CancelFuturesOrderUseCase>(),
        ));
    gh.factory<_i612.NotificationRepository>(
        () => _i883.NotificationRepositoryImpl(
              gh<_i251.NotificationRemoteDataSource>(),
              gh<_i499.NotificationWebSocketDataSource>(),
            ));
    gh.factory<_i860.GetFuturesMarketsUseCase>(() =>
        _i860.GetFuturesMarketsUseCase(gh<_i400.FuturesMarketRepository>()));
    gh.factory<_i870.GetTradingMarketsUseCase>(
        () => _i870.GetTradingMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i596.DepositRepository>(() => _i598.DepositRepositoryImpl(
          gh<_i587.DepositRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i692.TransferRepository>(() => _i411.TransferRepositoryImpl(
          gh<_i650.TransferRemoteDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i74.ConnectWebSocketUseCase>(
        () => _i74.ConnectWebSocketUseCase(gh<_i612.NotificationRepository>()));
    gh.factory<_i192.MarkAllNotificationsReadUseCase>(() =>
        _i192.MarkAllNotificationsReadUseCase(
            gh<_i612.NotificationRepository>()));
    gh.factory<_i560.GetNotificationsUseCase>(() =>
        _i560.GetNotificationsUseCase(gh<_i612.NotificationRepository>()));
    gh.factory<_i725.DeleteNotificationUseCase>(() =>
        _i725.DeleteNotificationUseCase(gh<_i612.NotificationRepository>()));
    gh.factory<_i534.MarkNotificationReadUseCase>(() =>
        _i534.MarkNotificationReadUseCase(gh<_i612.NotificationRepository>()));
    gh.factory<_i1073.GetLaunchPlansUseCase>(
        () => _i1073.GetLaunchPlansUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i739.GetInvestorsUseCase>(
        () => _i739.GetInvestorsUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i779.LaunchTokenUseCase>(
        () => _i779.LaunchTokenUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i223.GetCreatorStatsUseCase>(
        () => _i223.GetCreatorStatsUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i524.GetTeamMembersUseCase>(
        () => _i524.GetTeamMembersUseCase(gh<_i1017.CreatorRepository>()));
    gh.factory<_i574.GetCurrencyPriceUseCase>(() =>
        _i574.GetCurrencyPriceUseCase(gh<_i104.CurrencyPriceRepository>()));
    gh.factory<_i668.GetCurrencyWalletBalanceUseCase>(() =>
        _i668.GetCurrencyWalletBalanceUseCase(
            gh<_i104.CurrencyPriceRepository>()));
    gh.factory<_i518.FuturesPositionRepository>(
        () => _i840.FuturesPositionRepositoryImpl(
              gh<_i149.FuturesPositionRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i709.FuturesChartBloc>(() => _i709.FuturesChartBloc(
          gh<_i860.GetFuturesMarketsUseCase>(),
          gh<_i937.FuturesChartRemoteDataSource>(),
        ));
    gh.factory<_i854.ValidateDiscountUseCase>(
        () => _i854.ValidateDiscountUseCase(gh<_i222.DiscountRepository>()));
    gh.factory<_i191.GetIcoBlockchainsUseCase>(
        () => _i191.GetIcoBlockchainsUseCase(gh<_i834.IcoRepository>()));
    gh.factory<_i896.GetFeaturedIcoOfferingsUseCase>(
        () => _i896.GetFeaturedIcoOfferingsUseCase(gh<_i834.IcoRepository>()));
    gh.factory<_i109.GetIcoTokenTypesUseCase>(
        () => _i109.GetIcoTokenTypesUseCase(gh<_i834.IcoRepository>()));
    gh.factory<_i800.IcoBloc>(() => _i800.IcoBloc(gh<_i834.IcoRepository>()));
    gh.factory<_i362.EcoDepositRepository>(
        () => _i1033.EcoDepositRepositoryImpl(
              gh<_i221.EcoDepositRemoteDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i907.GetUserReviewsUseCase>(
        () => _i907.GetUserReviewsUseCase(gh<_i617.P2PReviewsRepository>()));
    gh.factory<_i610.GetReviewsUseCase>(
        () => _i610.GetReviewsUseCase(gh<_i617.P2PReviewsRepository>()));
    gh.factory<_i457.EcommerceRepository>(() => _i754.EcommerceRepositoryImpl(
          gh<_i202.EcommerceRemoteDataSource>(),
          gh<_i1031.EcommerceLocalDataSource>(),
          gh<_i821.NetworkInfo>(),
        ));
    gh.factory<_i1013.MlmConditionsBloc>(
        () => _i1013.MlmConditionsBloc(gh<_i417.GetMlmConditionsUseCase>()));
    gh.factory<_i626.StatsCubit>(
        () => _i626.StatsCubit(gh<_i223.GetCreatorStatsUseCase>()));
    gh.factory<_i871.GetDashboardStatsUseCase>(() =>
        _i871.GetDashboardStatsUseCase(gh<_i556.P2PDashboardRepository>()));
    gh.factory<_i609.GetTradingActivityUseCase>(() =>
        _i609.GetTradingActivityUseCase(gh<_i556.P2PDashboardRepository>()));
    gh.factory<_i791.GetDashboardDataUseCase>(() =>
        _i791.GetDashboardDataUseCase(gh<_i556.P2PDashboardRepository>()));
    gh.factory<_i993.GetPortfolioDataUseCase>(() =>
        _i993.GetPortfolioDataUseCase(gh<_i556.P2PDashboardRepository>()));
    gh.factory<_i670.GetRealtimeMarketsUseCase>(
        () => _i670.GetRealtimeMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetMarketsUseCase>(
        () => _i1067.GetMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetTrendingMarketsUseCase>(
        () => _i1067.GetTrendingMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetHotMarketsUseCase>(
        () => _i1067.GetHotMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetGainersMarketsUseCase>(
        () => _i1067.GetGainersMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetLosersMarketsUseCase>(
        () => _i1067.GetLosersMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetHighVolumeMarketsUseCase>(
        () => _i1067.GetHighVolumeMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.SearchMarketsUseCase>(
        () => _i1067.SearchMarketsUseCase(gh<_i792.MarketRepository>()));
    gh.factory<_i1067.GetMarketsByCategoryUseCase>(
        () => _i1067.GetMarketsByCategoryUseCase(gh<_i792.MarketRepository>()));
    gh.lazySingleton<_i244.GetOrderHistoryUseCase>(
        () => _i244.GetOrderHistoryUseCase(gh<_i669.OrderRepository>()));
    gh.lazySingleton<_i989.GetOpenOrdersUseCase>(
        () => _i989.GetOpenOrdersUseCase(gh<_i669.OrderRepository>()));
    gh.factory<_i293.PlaceOrderUseCase>(
        () => _i293.PlaceOrderUseCase(gh<_i669.OrderRepository>()));
    gh.factory<_i833.GuidedMatchingBloc>(() => _i833.GuidedMatchingBloc(
          gh<_i870.GuidedMatchingUseCase>(),
          gh<_i1069.ComparePricesUseCase>(),
        ));
    gh.factory<_i732.NewsBloc>(() => _i732.NewsBloc(
          gh<_i1048.GetLatestNewsUseCase>(),
          gh<_i868.GetTrendingNewsUseCase>(),
          gh<_i990.SearchNewsUseCase>(),
          gh<_i547.GetNewsCategoriesUseCase>(),
          gh<_i506.NewsRepository>(),
        ));
    gh.factory<_i367.GetSpotCurrenciesUseCase>(() =>
        _i367.GetSpotCurrenciesUseCase(gh<_i178.SpotDepositRepository>()));
    gh.factory<_i109.GenerateSpotDepositAddressUseCase>(() =>
        _i109.GenerateSpotDepositAddressUseCase(
            gh<_i178.SpotDepositRepository>()));
    gh.factory<_i298.CreateSpotDepositUseCase>(() =>
        _i298.CreateSpotDepositUseCase(gh<_i178.SpotDepositRepository>()));
    gh.factory<_i402.GetSpotNetworksUseCase>(
        () => _i402.GetSpotNetworksUseCase(gh<_i178.SpotDepositRepository>()));
    gh.factory<_i358.VerifySpotDepositUseCase>(() =>
        _i358.VerifySpotDepositUseCase(gh<_i178.SpotDepositRepository>()));
    gh.factory<_i767.GetTransferOptionsUseCase>(
        () => _i767.GetTransferOptionsUseCase(gh<_i692.TransferRepository>()));
    gh.factory<_i58.CreateTransferUseCase>(
        () => _i58.CreateTransferUseCase(gh<_i692.TransferRepository>()));
    gh.factory<_i166.GetWalletBalanceUseCase>(
        () => _i166.GetWalletBalanceUseCase(gh<_i692.TransferRepository>()));
    gh.factory<_i942.GetTransferCurrenciesUseCase>(() =>
        _i942.GetTransferCurrenciesUseCase(gh<_i692.TransferRepository>()));
    gh.factory<_i8.CreatePaymentMethodUseCase>(() =>
        _i8.CreatePaymentMethodUseCase(gh<_i32.P2PPaymentMethodsRepository>()));
    gh.factory<_i320.GetPaymentMethodsUseCase>(() =>
        _i320.GetPaymentMethodsUseCase(gh<_i32.P2PPaymentMethodsRepository>()));
    gh.factory<_i200.DeletePaymentMethodUseCase>(() =>
        _i200.DeletePaymentMethodUseCase(
            gh<_i32.P2PPaymentMethodsRepository>()));
    gh.factory<_i339.CreatePaymentMethodUseCase>(() =>
        _i339.CreatePaymentMethodUseCase(
            gh<_i32.P2PPaymentMethodsRepository>()));
    gh.factory<_i350.UpdatePaymentMethodUseCase>(() =>
        _i350.UpdatePaymentMethodUseCase(
            gh<_i32.P2PPaymentMethodsRepository>()));
    gh.factory<_i600.CreateFiatDepositUseCase>(
        () => _i600.CreateFiatDepositUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i707.GetDepositMethodsUseCase>(
        () => _i707.GetDepositMethodsUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i35.VerifyStripePaymentUseCase>(
        () => _i35.VerifyStripePaymentUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i798.GetCurrencyOptionsUseCase>(
        () => _i798.GetCurrencyOptionsUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i240.CreatePayPalOrderUseCase>(
        () => _i240.CreatePayPalOrderUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i902.CreateStripePaymentIntentUseCase>(() =>
        _i902.CreateStripePaymentIntentUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i881.VerifyPayPalPaymentUseCase>(
        () => _i881.VerifyPayPalPaymentUseCase(gh<_i596.DepositRepository>()));
    gh.factory<_i810.P2PRecommendationRepository>(
        () => _i1021.P2PRecommendationRepositoryImpl(
              gh<_i679.P2PRecommendationRemoteDataSource>(),
              gh<_i816.P2PRecommendationLocalDataSource>(),
              gh<_i821.NetworkInfo>(),
            ));
    gh.factory<_i74.MarketBloc>(() => _i74.MarketBloc(
          gh<_i1067.GetMarketsUseCase>(),
          gh<_i1067.GetTrendingMarketsUseCase>(),
          gh<_i1067.GetHotMarketsUseCase>(),
          gh<_i1067.GetGainersMarketsUseCase>(),
          gh<_i1067.GetLosersMarketsUseCase>(),
          gh<_i1067.GetHighVolumeMarketsUseCase>(),
          gh<_i1067.SearchMarketsUseCase>(),
          gh<_i1067.GetMarketsByCategoryUseCase>(),
          gh<_i670.GetRealtimeMarketsUseCase>(),
          gh<_i903.MarketService>(),
        ));
    gh.factory<_i963.TradingChartBloc>(() => _i963.TradingChartBloc(
          gh<_i270.GetTradingChartHistoryUseCase>(),
          gh<_i458.TradingWebSocketService>(),
        ));
    gh.factory<_i354.DashboardBloc>(() => _i354.DashboardBloc(
          gh<_i903.MarketService>(),
          gh<_i711.GlobalNotificationService>(),
          gh<_i183.WalletRepository>(),
          gh<_i873.DioClient>(),
        ));
    gh.factory<_i578.TradeExecutionBloc>(() => _i578.TradeExecutionBloc(
          gh<_i739.InitiateTradeUseCase>(),
          gh<_i0.ConfirmTradeUseCase>(),
          gh<_i362.CancelTradeUseCase>(),
          gh<_i624.ReleaseEscrowUseCase>(),
          gh<_i975.DisputeTradeUseCase>(),
        ));
    gh.factory<_i606.TransferBloc>(() => _i606.TransferBloc(
          gh<_i767.GetTransferOptionsUseCase>(),
          gh<_i942.GetTransferCurrenciesUseCase>(),
          gh<_i166.GetWalletBalanceUseCase>(),
          gh<_i58.CreateTransferUseCase>(),
          gh<_i692.TransferRepository>(),
        ));
    gh.factory<_i725.CreateSupportTicketUseCase>(
        () => _i725.CreateSupportTicketUseCase(gh<_i293.SupportRepository>()));
    gh.factory<_i715.LiveChatUseCase>(
        () => _i715.LiveChatUseCase(gh<_i293.SupportRepository>()));
    gh.factory<_i776.GetSupportTicketsUseCase>(
        () => _i776.GetSupportTicketsUseCase(gh<_i293.SupportRepository>()));
    gh.factory<_i628.ReplyToTicketUseCase>(
        () => _i628.ReplyToTicketUseCase(gh<_i293.SupportRepository>()));
    gh.factory<_i844.TicketDetailBloc>(
        () => _i844.TicketDetailBloc(gh<_i293.SupportRepository>()));
    gh.factory<_i317.CreatePriceAlertUseCase>(() =>
        _i317.CreatePriceAlertUseCase(gh<_i810.P2PRecommendationRepository>()));
    gh.factory<_i298.GetRecommendationsUseCase>(() =>
        _i298.GetRecommendationsUseCase(
            gh<_i810.P2PRecommendationRepository>()));
    gh.factory<_i293.ManageRecommendationsUseCase>(() =>
        _i293.ManageRecommendationsUseCase(
            gh<_i810.P2PRecommendationRepository>()));
    gh.factory<_i452.GetSettingsUseCase>(
        () => _i452.GetSettingsUseCase(gh<_i360.SettingsRepository>()));
    gh.factory<_i632.UpdateSettingsUseCase>(
        () => _i632.UpdateSettingsUseCase(gh<_i360.SettingsRepository>()));
    gh.factory<_i759.GetProductsUseCase>(
        () => _i759.GetProductsUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i901.GetCategoriesUseCase>(
        () => _i901.GetCategoriesUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i358.AddReviewUseCase>(
        () => _i358.AddReviewUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i832.OffersBloc>(() => _i832.OffersBloc(
          gh<_i993.GetOffersUseCase>(),
          gh<_i406.GetOfferByIdUseCase>(),
          gh<_i695.GetPopularOffersUseCase>(),
          gh<_i870.GuidedMatchingUseCase>(),
        ));
    gh.factory<_i550.GetWithdrawCurrenciesUseCase>(() =>
        _i550.GetWithdrawCurrenciesUseCase(gh<_i84.WithdrawRepository>()));
    gh.factory<_i1071.GetWithdrawMethodsUseCase>(
        () => _i1071.GetWithdrawMethodsUseCase(gh<_i84.WithdrawRepository>()));
    gh.factory<_i433.SubmitWithdrawUseCase>(
        () => _i433.SubmitWithdrawUseCase(gh<_i84.WithdrawRepository>()));
    gh.factory<_i658.ChangeLeverageUseCase>(() =>
        _i658.ChangeLeverageUseCase(gh<_i518.FuturesPositionRepository>()));
    gh.factory<_i88.ClosePositionUseCase>(
        () => _i88.ClosePositionUseCase(gh<_i518.FuturesPositionRepository>()));
    gh.factory<_i965.GetFuturesPositionsUseCase>(() =>
        _i965.GetFuturesPositionsUseCase(
            gh<_i518.FuturesPositionRepository>()));
    gh.factory<_i47.CreatorBloc>(() => _i47.CreatorBloc(
          gh<_i1017.CreatorRepository>(),
          gh<_i779.LaunchTokenUseCase>(),
        ));
    gh.factory<_i397.GetFuturesTokensUseCase>(() =>
        _i397.GetFuturesTokensUseCase(gh<_i257.FuturesDepositRepository>()));
    gh.factory<_i716.GenerateFuturesAddressUseCase>(() =>
        _i716.GenerateFuturesAddressUseCase(
            gh<_i257.FuturesDepositRepository>()));
    gh.factory<_i467.GetFuturesCurrenciesUseCase>(() =>
        _i467.GetFuturesCurrenciesUseCase(
            gh<_i257.FuturesDepositRepository>()));
    gh.factory<_i186.TradingFormBloc>(() => _i186.TradingFormBloc(
          gh<_i293.PlaceOrderUseCase>(),
          gh<_i458.TradingWebSocketService>(),
          gh<_i402.GetSymbolBalancesUseCase>(),
        ));
    gh.factory<_i158.NotificationBloc>(() => _i158.NotificationBloc(
          gh<_i612.NotificationRepository>(),
          gh<_i560.GetNotificationsUseCase>(),
          gh<_i534.MarkNotificationReadUseCase>(),
          gh<_i192.MarkAllNotificationsReadUseCase>(),
          gh<_i725.DeleteNotificationUseCase>(),
          gh<_i74.ConnectWebSocketUseCase>(),
        ));
    gh.factory<_i554.TransactionBloc>(() => _i554.TransactionBloc(
          gh<_i151.GetTransactionsUseCase>(),
          gh<_i878.GetTransactionDetailsUseCase>(),
          gh<_i297.SearchTransactionsUseCase>(),
        ));
    gh.factory<_i1051.FuturesHeaderBloc>(() => _i1051.FuturesHeaderBloc(
          gh<_i860.GetFuturesMarketsUseCase>(),
          gh<_i244.FuturesWebSocketService>(),
          gh<_i668.GetCurrencyWalletBalanceUseCase>(),
        ));
    gh.factory<_i624.KycBloc>(() => _i624.KycBloc(
          gh<_i540.GetKycLevelsUseCase>(),
          gh<_i452.GetKycLevelByIdUseCase>(),
          gh<_i246.GetKycApplicationsUseCase>(),
          gh<_i811.SubmitKycApplicationUseCase>(),
          gh<_i711.UpdateKycApplicationUseCase>(),
          gh<_i448.UploadKycDocumentUseCase>(),
        ));
    gh.factory<_i277.WithdrawBloc>(() => _i277.WithdrawBloc(
          gh<_i550.GetWithdrawCurrenciesUseCase>(),
          gh<_i1071.GetWithdrawMethodsUseCase>(),
          gh<_i433.SubmitWithdrawUseCase>(),
        ));
    gh.factory<_i898.CategoriesBloc>(() => _i898.CategoriesBloc(
        getCategoriesUseCase: gh<_i901.GetCategoriesUseCase>()));
    gh.factory<_i491.GetAiInvestmentPlansUseCase>(() =>
        _i491.GetAiInvestmentPlansUseCase(gh<_i667.AiInvestmentRepository>()));
    gh.factory<_i557.CreateAiInvestmentUseCase>(() =>
        _i557.CreateAiInvestmentUseCase(gh<_i667.AiInvestmentRepository>()));
    gh.factory<_i927.GetUserAiInvestmentsUseCase>(() =>
        _i927.GetUserAiInvestmentsUseCase(gh<_i667.AiInvestmentRepository>()));
    gh.factory<_i413.DepositBloc>(() => _i413.DepositBloc(
          gh<_i798.GetCurrencyOptionsUseCase>(),
          gh<_i707.GetDepositMethodsUseCase>(),
          gh<_i600.CreateFiatDepositUseCase>(),
          gh<_i902.CreateStripePaymentIntentUseCase>(),
          gh<_i35.VerifyStripePaymentUseCase>(),
          gh<_i240.CreatePayPalOrderUseCase>(),
          gh<_i881.VerifyPayPalPaymentUseCase>(),
        ));
    gh.factory<_i1010.SpotDepositBloc>(() => _i1010.SpotDepositBloc(
          gh<_i367.GetSpotCurrenciesUseCase>(),
          gh<_i402.GetSpotNetworksUseCase>(),
          gh<_i109.GenerateSpotDepositAddressUseCase>(),
          gh<_i298.CreateSpotDepositUseCase>(),
          gh<_i358.VerifySpotDepositUseCase>(),
        ));
    gh.factory<_i399.ShopBloc>(() => _i399.ShopBloc(
          gh<_i759.GetProductsUseCase>(),
          gh<_i901.GetCategoriesUseCase>(),
        ));
    gh.factory<_i430.LiveChatBloc>(() => _i430.LiveChatBloc(
          gh<_i715.LiveChatUseCase>(),
          gh<_i520.AuthBloc>(),
        ));
    gh.factory<_i128.InvestorsCubit>(
        () => _i128.InvestorsCubit(gh<_i739.GetInvestorsUseCase>()));
    gh.factory<_i23.LaunchPlanCubit>(
        () => _i23.LaunchPlanCubit(gh<_i1073.GetLaunchPlansUseCase>()));
    gh.factory<_i495.P2PRecommendationsBloc>(() => _i495.P2PRecommendationsBloc(
          gh<_i298.GetRecommendationsUseCase>(),
          gh<_i317.CreatePriceAlertUseCase>(),
          gh<_i293.ManageRecommendationsUseCase>(),
        ));
    gh.factory<_i61.GetSavedThemeUseCase>(
        () => _i61.GetSavedThemeUseCase(gh<_i574.ThemeRepository>()));
    gh.factory<_i223.GetSystemThemeUseCase>(
        () => _i223.GetSystemThemeUseCase(gh<_i574.ThemeRepository>()));
    gh.factory<_i2.SaveThemeUseCase>(
        () => _i2.SaveThemeUseCase(gh<_i574.ThemeRepository>()));
    gh.factory<_i529.P2PUserProfileBloc>(
        () => _i529.P2PUserProfileBloc(gh<_i907.GetUserReviewsUseCase>()));
    gh.factory<_i950.ThemeBloc>(() => _i950.ThemeBloc(
          gh<_i61.GetSavedThemeUseCase>(),
          gh<_i2.SaveThemeUseCase>(),
          gh<_i223.GetSystemThemeUseCase>(),
        ));
    gh.factory<_i558.CurrencyPriceBloc>(() => _i558.CurrencyPriceBloc(
          gh<_i574.GetCurrencyPriceUseCase>(),
          gh<_i668.GetCurrencyWalletBalanceUseCase>(),
        ));
    gh.factory<_i823.CreateOfferBloc>(() => _i823.CreateOfferBloc(
          gh<_i283.CreateOfferUseCase>(),
          gh<_i320.GetPaymentMethodsUseCase>(),
          gh<_i8.CreatePaymentMethodUseCase>(),
          gh<_i668.GetCurrencyWalletBalanceUseCase>(),
          gh<_i873.DioClient>(),
        ));
    gh.factory<_i849.SupportTicketsBloc>(() => _i849.SupportTicketsBloc(
          gh<_i776.GetSupportTicketsUseCase>(),
          gh<_i725.CreateSupportTicketUseCase>(),
        ));
    gh.factory<_i648.GetOrdersUseCase>(
        () => _i648.GetOrdersUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i238.AddToCartUseCase>(
        () => _i238.AddToCartUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i523.TrackOrderUseCase>(
        () => _i523.TrackOrderUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i380.GetWishlistUseCase>(
        () => _i380.GetWishlistUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i959.RemoveFromCartUseCase>(
        () => _i959.RemoveFromCartUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i82.GetOrderByIdUseCase>(
        () => _i82.GetOrderByIdUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i409.GetCartUseCase>(
        () => _i409.GetCartUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i876.UpdateCartItemQuantityUseCase>(() =>
        _i876.UpdateCartItemQuantityUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i812.DownloadDigitalProductUseCase>(() =>
        _i812.DownloadDigitalProductUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i920.RemoveFromWishlistUseCase>(
        () => _i920.RemoveFromWishlistUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i514.GetProductsByCategoryUseCase>(() =>
        _i514.GetProductsByCategoryUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i869.AddToWishlistUseCase>(
        () => _i869.AddToWishlistUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i922.ClearCartUseCase>(
        () => _i922.ClearCartUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i586.PlaceOrderUseCase>(
        () => _i586.PlaceOrderUseCase(gh<_i457.EcommerceRepository>()));
    gh.factory<_i1027.PaymentMethodsBloc>(() => _i1027.PaymentMethodsBloc(
          gh<_i320.GetPaymentMethodsUseCase>(),
          gh<_i339.CreatePaymentMethodUseCase>(),
          gh<_i350.UpdatePaymentMethodUseCase>(),
          gh<_i200.DeletePaymentMethodUseCase>(),
        ));
    gh.factory<_i978.FuturesPositionsBloc>(() => _i978.FuturesPositionsBloc(
          gh<_i965.GetFuturesPositionsUseCase>(),
          gh<_i88.ClosePositionUseCase>(),
        ));
    gh.factory<_i288.TradingHeaderBloc>(() => _i288.TradingHeaderBloc(
          gh<_i1067.GetMarketsUseCase>(),
          gh<_i546.ConnectTradingWebSocketUseCase>(),
          gh<_i458.TradingWebSocketService>(),
          gh<_i903.MarketService>(),
        ));
    gh.factory<_i111.FuturesFormBloc>(() => _i111.FuturesFormBloc(
          gh<_i888.PlaceFuturesOrderUseCase>(),
          gh<_i658.ChangeLeverageUseCase>(),
        ));
    gh.factory<_i951.GetEcoCurrenciesUseCase>(
        () => _i951.GetEcoCurrenciesUseCase(gh<_i362.EcoDepositRepository>()));
    gh.factory<_i516.GetEcoTokensUseCase>(
        () => _i516.GetEcoTokensUseCase(gh<_i362.EcoDepositRepository>()));
    gh.factory<_i948.GenerateEcoAddressUseCase>(() =>
        _i948.GenerateEcoAddressUseCase(gh<_i362.EcoDepositRepository>()));
    gh.factory<_i574.TradingPairSelectorBloc>(
        () => _i574.TradingPairSelectorBloc(
              gh<_i1067.GetMarketsUseCase>(),
              gh<_i670.GetRealtimeMarketsUseCase>(),
            ));
    gh.factory<_i892.OrderTabsBloc>(() => _i892.OrderTabsBloc(
          gh<_i989.GetOpenOrdersUseCase>(),
          gh<_i244.GetOrderHistoryUseCase>(),
        ));
    gh.factory<_i1018.CheckoutBloc>(() => _i1018.CheckoutBloc(
          gh<_i586.PlaceOrderUseCase>(),
          gh<_i409.GetCartUseCase>(),
        ));
    gh.factory<_i454.SettingsService>(() => _i454.SettingsService(
          gh<_i452.GetSettingsUseCase>(),
          gh<_i602.SettingsLocalDataSource>(),
        ));
    gh.factory<_i293.SettingsBloc>(() => _i293.SettingsBloc(
          gh<_i452.GetSettingsUseCase>(),
          gh<_i632.UpdateSettingsUseCase>(),
        ));
    gh.factory<_i208.AiInvestmentBloc>(() => _i208.AiInvestmentBloc(
          gh<_i491.GetAiInvestmentPlansUseCase>(),
          gh<_i927.GetUserAiInvestmentsUseCase>(),
          gh<_i557.CreateAiInvestmentUseCase>(),
        ));
    gh.factory<_i152.ProductsBloc>(() => _i152.ProductsBloc(
          getProductsUseCase: gh<_i759.GetProductsUseCase>(),
          getCategoriesUseCase: gh<_i901.GetCategoriesUseCase>(),
        ));
    gh.factory<_i7.FuturesDepositBloc>(() => _i7.FuturesDepositBloc(
          gh<_i467.GetFuturesCurrenciesUseCase>(),
          gh<_i397.GetFuturesTokensUseCase>(),
          gh<_i716.GenerateFuturesAddressUseCase>(),
          gh<_i257.FuturesDepositRepository>(),
        ));
    gh.factory<_i863.OrdersBloc>(
        () => _i863.OrdersBloc(getOrdersUseCase: gh<_i648.GetOrdersUseCase>()));
    gh.factory<_i932.CategoryProductsBloc>(() => _i932.CategoryProductsBloc(
        getProductsByCategoryUseCase:
            gh<_i514.GetProductsByCategoryUseCase>()));
    gh.factory<_i1045.CartBloc>(() => _i1045.CartBloc(
          getCartUseCase: gh<_i409.GetCartUseCase>(),
          addToCartUseCase: gh<_i238.AddToCartUseCase>(),
          updateCartItemQuantityUseCase:
              gh<_i876.UpdateCartItemQuantityUseCase>(),
          removeFromCartUseCase: gh<_i959.RemoveFromCartUseCase>(),
          clearCartUseCase: gh<_i922.ClearCartUseCase>(),
        ));
    gh.factory<_i233.EcoDepositBloc>(() => _i233.EcoDepositBloc(
          gh<_i951.GetEcoCurrenciesUseCase>(),
          gh<_i516.GetEcoTokensUseCase>(),
          gh<_i948.GenerateEcoAddressUseCase>(),
          gh<_i362.EcoDepositRepository>(),
        ));
    gh.factory<_i314.OrderDetailBloc>(() => _i314.OrderDetailBloc(
        getOrderByIdUseCase: gh<_i82.GetOrderByIdUseCase>()));
    return this;
  }
}
