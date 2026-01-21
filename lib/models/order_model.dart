import 'dart:convert';
import 'package:collection/collection.dart';

class Order {
  final List<Item> items;
  Order({
    required this.items,
  });

  Order copyWith({
    List<Item>? items,
  }) {
    return Order(
      items: items ?? this.items,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'items': items.map((x) => x.toMap()).toList(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      items: List<Item>.from((map['items'] as List<int>).map<Item>((x) => Item.fromMap(x as Map<String,dynamic>),),),
    );
  }

  String toJson() => json.encode(toMap());

  factory Order.fromJson(String source) => Order.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Order(items: $items)';

  @override
  bool operator ==(covariant Order other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;
  
    return 
      listEquals(other.items, items);
  }

  @override
  int get hashCode => items.hashCode;
}

class Item {
  final int menu_id;
  final int qty;
  Item({
    required this.menu_id,
    required this.qty,
  });

  Item copyWith({
    int? menu_id,
    int? qty,
  }) {
    return Item(
      menu_id: menu_id ?? this.menu_id,
      qty: qty ?? this.qty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'menu_id': menu_id,
      'qty': qty,
    };
  }

  factory Item.fromMap(Map<String, dynamic> map) {
    return Item(
      menu_id: map['menu_id'].toInt() as int,
      qty: map['qty'].toInt() as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Item.fromJson(String source) => Item.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Item(menu_id: $menu_id, qty: $qty)';

  @override
  bool operator ==(covariant Item other) {
    if (identical(this, other)) return true;
  
    return 
      other.menu_id == menu_id &&
      other.qty == qty;
  }

  @override
  int get hashCode => menu_id.hashCode ^ qty.hashCode;
}