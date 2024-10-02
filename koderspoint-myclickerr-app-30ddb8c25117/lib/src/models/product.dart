class Product {
  int id;
  String name;
  String imageURL;
  String description;
  double price;
  String webURL;

  Product(this.id, this.name, this.imageURL, this.description, this.price,
      this.webURL);

  factory Product.fromJson(Map<String, dynamic> data) {
    return Product(data['id'], data['product_name'], data['product_image'],
        data['product_description'], 100, data['web_url']);
  }
}
