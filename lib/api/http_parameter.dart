import 'package:flutter/material.dart';
class HttpParams
{
  static const String API_USER="api/auth/check-user";
  static const String API_UPDATE_USER_PROFILE="api/user/update-profile";
  static const String API_GET_USER_PROFILE="api/user/get-profile";
  static const String API_GET_USER_PRODUCT="api/products/get-all-products";
  static const String API_UPDATE_PRODUCT="api/products/update-product/";
  static const String API_USER_INVISIBLE="api/user/go-invisible";
  static const String API_USER_VISIBLE="api/user/go-visible";
  static const String API_USER_LIKED_PRODUCT='api/like/liked-products';
  static const String API_HIDE_USER_PRODUCT="api/user/unlist-products";
  static const String API_USER_PRODUCT_TRADED="api/products/make-traded/";
  static const String API_USER_PRODUCT_UNTRADED="api/products/make-untraded/";
  static const String API_USER_BLOCK="api/block/block-user";
  static const String API_USER_UNBLOCK="api/block/unblock-user/";
  static const String API_ADD_PRODUCT="api/products/add-product";
  static const String API_PRODUCT_DETAILS="api/products/get-product/";
  static const String API_DELETE_PRODUCT="api/products/remove-product/";
  static const String API_CATEGORIES="api/category/get-all-categories";
  static const String API_SUBCATEGORIES='api/category/get-sub-categories/';
  static const String API_GET_MARKETPLACE_ITEMS='api/marketplace/get-items';
  static const String API_PAGE_NO="?page=";
  static const String API_SEARCH="api/marketplace/search-items";
  static const String API_firstLike='api/like/make-like';
  static const String API_UNLIKE="api/like/make-unlike";
  static const String API_COUNTERLIKE='api/like/counter-like';
  static const String API_REPORT_PRODUCT="api/report/report-product";
  static const String API_GET_NOTIFICATION="api/notifications/get-notifications";
  static const String API_GET_NOTIFICATION_USER='api/products/products-of-user/';
  static const String API_GET_UPDATE_DISTANCE="api/user/update-distance/";
  static const String API_GO_INVISIBLE="api/user/go-invisible";
  static const String API_GO_VISIBLE="api/user/go-visible";
  static const String API_UNLIST_COLLECTION="api/user/unlist-products";
  static const String API_DACTIVATE_ACCOUNT="api/user/deactivate-account/";
  static const String API_APP_SETTINGS='api/user/app-settings';
  static const String API_CREATE_CHAT="api/chats/create-chat";
  static const String API_GET_ACTIVE_CHAT="api/chats/get-active-chats";
  static const String API_SHARE_PRODUCT="api/products/share-product/";//get imageurl for share
}