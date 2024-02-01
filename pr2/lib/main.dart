import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Danh sach san pham',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(), // home: ProductListScreen(),
    );
  }
}
//dinh nghia HomeScreen
class HomeScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Trang chu"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: (){
            Navigator.push(context,
              MaterialPageRoute(builder: (context)=>ProductListScreen()),);
          },
          child: Text('Go to ProductListScreen'),
        ),
      ),
    );

  }

}
class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen>{
  late List<Product> product;
  //khoi tao gio hang
  final Cart cart = Cart();
  //ham khoi tao
  @override
  void initState() {
    // TODO: implement initState
    //Khoi tao
    super.initState();
    product=[];
    fetchProduct();
  }
  //convert tu Map sang List
  List<Product> convertMapToProductList(Map<String,dynamic> data){
    List<Product> productList=[];
    data.forEach((key, value) {
      for(int i=0;i<value.length;i++)
      {
        Product product=Product(
            search_image: value[i]['search_image']?? '',
            styleid: value[i]['styleid']??0,
            brands_filter_facet: value[i]['brands_filter_facet']??'',
            price: value[i]['price']??0,
            product_additional_info: value[i]['product_additional_info']??'');
        productList.add(product);
      }
    });
    return productList;
  }
  //--ham doc du lieu tu server
  Future<void> fetchProduct() async {
    final response = await http.get(Uri.parse("http://192.168.1.38/asever/api.php"));
    if(response.statusCode==200){
      final Map<String,dynamic> data=json.decode(response.body);
      setState(() {
        product=convertMapToProductList(data);
      });
    }
    else {
      throw Exception("khong load duoc du lieu");
    }
  }
//---
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sach san pham'),
      ),
      body: product!=null ?
      ListView.builder(
        itemCount: product.length,
        itemBuilder: (context,index){
          return ListTile(
              title: Text(product[index].brands_filter_facet),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price: ${product[index].price}'),
                  Text('product_additional_info: ${product[index].product_additional_info}'),
                ],
              ),
              leading: Image.network(
                product[index].search_image,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              onTap: (){//click vào item
                Navigator.push(context, 
                  MaterialPageRoute(builder: (context)=> ProductDetailScreen(product[index], cart),
                  ),
                );
                },
          );
        },
      )
          :Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
//dinh nghia chi tiet san pham
class ProductDetailScreen extends StatelessWidget{
  final Product product;
  final Cart cart;
  ProductDetailScreen(this.product, this.cart);
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('Product Detail'),
        actions: [
          ElevatedButton(onPressed: (){
            cart.addToCart(product);//them sp vào gio hang
            //dua ra thong bao
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('San pham da duoc them vao gio'),
              ),
            );
            Navigator.push(context, 
                MaterialPageRoute(builder: (context)=> CartScreen(cart)),
            );
          }, 
              child: Icon(Icons.shopping_cart),
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                padding: EdgeInsets.all(0)
              ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.all(8),
          child: Text('Brand: ${product.brands_filter_facet}'),
          ),
          Image.network(product.search_image),
          Padding(padding: const EdgeInsets.all(8),
            child: Text(product.product_additional_info,
              style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),
            ),
          ),
          Padding(padding: const EdgeInsets.all(8),
          child: Text('ID: ${product.styleid}'),
          ),
          Padding(padding: const EdgeInsets.all(8),
          child: Text('Price: ${product.price}'),
          )
        ],
      ),
    );
  }
}
class CartScreen extends StatelessWidget{
  final Cart cart;
  CartScreen(this.cart);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shopping Cart"),),
      body: ListView.builder(
          itemCount: cart.items.length, //so lương item
          itemBuilder: (context, index){
            return ListTile(
              title: Text(cart.items[index].search_image),
              subtitle: Text(cart.items[index].price),
            );
          }),
    );
  }
}
//xu li gio hang
class Cart{
  List<Product> items =[];
  void addToCart(Product p){
    //them san pham vao gio hang
    items.add(p);
  }
}
//--
class Product{
  String search_image;
  String styleid;
  String brands_filter_facet;
  String price;
  String product_additional_info;

  Product({ required this.search_image,
    required this.styleid,
    required this.brands_filter_facet,
    required this.price,
    required this.product_additional_info});
}
//-----
