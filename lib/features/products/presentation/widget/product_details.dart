import 'package:e_commerce/core/utilits/app_lottie.dart';
import 'package:e_commerce/features/navigation_layout/tabs/favorite/cubit/favorites_cubit.dart';
import 'package:e_commerce/features/navigation_layout/tabs/home/cubit/products/products_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:e_commerce/core/models/product_model.dart';
import 'package:e_commerce/features/cart/presentation/bloc/cart_bloc.dart';
import 'package:lottie/lottie.dart';

class ProductDetails extends StatefulWidget {
  final int productId;

  const ProductDetails({super.key, required this.productId});

  @override
  State<ProductDetails> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetails> {
  String? selectedSize;
  String? selectedColor;
  int quantity = 1;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    // Load product data
    context.read<ProductsCubit>().loadProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          BlocBuilder<FavoritesCubit, FavoritesState>(
            builder: (context, state) {
              final isFavorite = state.ids.contains(widget.productId);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: () {
                  context.read<FavoritesCubit>().toggleFavorite(
                    widget.productId,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<ProductsCubit, ProductsState>(
        builder: (context, state) {
          if (state.status == ProductsStatus.loading) {
            return Center(child: Lottie.asset(AppLottie.loading));
          }

          if (state.status == ProductsStatus.failure ||
              state.selectedProduct == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(AppLottie.offline, width: 180),
                  const SizedBox(height: 16),
                  const Text(
                    'No Internet Connection',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please check your connection and try again',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      context.read<ProductsCubit>().loadProductById(
                        widget.productId,
                      );
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final product = state.selectedProduct!;
          return _buildProductDetails(product);
        },
      ),
    );
  }

  Widget _buildProductDetails(Product product) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product images
            _buildProductImages(product),

            const SizedBox(height: 16),

            // Product header
            _buildProductHeader(product),

            const SizedBox(height: 16),

            // Price section
            _buildPriceSection(product),

            const SizedBox(height: 16),

            // Description
            _buildDescription(product),

            const SizedBox(height: 20),

            // Size section
            _buildSizeSection(product),

            const SizedBox(height: 20),

            // Color section
            _buildColorSection(product),

            const SizedBox(height: 30),

            // Bottom section
            _buildBottomSection(product),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImages(Product product) {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade50, // Slightly lighter background
        borderRadius: BorderRadius.circular(20),
      ),
      child: product.images.isNotEmpty
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: product.images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.network(
                        product.images[index],
                        fit: BoxFit.contain, // Show whole product
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 64,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
                if (product.images.length > 1)
                  Positioned(
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(
                          product.images.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentImageIndex == index ? 20 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentImageIndex == index
                                  ? Colors.white
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            )
          : const Center(
              child: Icon(
                Icons.image_not_supported,
                size: 64,
                color: Colors.grey,
              ),
            ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.shopping_bag, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              '3,230 sold', // You can put a real number from data here
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(width: 16),
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
            const Text('4.8 (7,500)', style: TextStyle(color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Price',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          Text(
            'EGP ${product.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(Product product) {
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              product.description,
              maxLines: isExpanded ? null : 3,
              overflow: isExpanded ? null : TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            if (product.description.length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Text(
                  isExpanded ? 'Read Less' : 'Read More',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildSizeSection(Product product) {
    if (product.size == null || product.size!.isEmpty) {
      return const SizedBox.shrink();
    }

    final sizes = product.size!.split(',').map((e) => e.trim()).toList();
    if (selectedSize == null && sizes.isNotEmpty) {
      // Set default selection if not set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedSize = sizes.first;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Size',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: sizes.map((size) {
            bool isSelected = selectedSize == size;
            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedSize = size;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  size,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildColorSection(Product product) {
    if (product.color == null || product.color!.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = product.color!.split(',').map((e) => e.trim()).toList();
    if (selectedColor == null && colors.isNotEmpty) {
      // Set default selection if not set
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            selectedColor = colors.first;
          });
        }
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Color',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: colors.map((colorName) {
            bool isSelected = selectedColor == colorName;
            final colorValue = _getColorFromString(colorName);

            return GestureDetector(
              onTap: () {
                setState(() {
                  selectedColor = colorName;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade50 : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey.shade300,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: colorValue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      colorName,
                      style: TextStyle(
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isSelected ? Colors.blue : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorFromString(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'brown':
        return Colors.brown;
      case 'pink':
        return Colors.pink;
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildBottomSection(Product product) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Price',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'EGP ${(product.price * quantity).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                // Add to cart
                context.read<CartBloc>().add(
                  AddToCartEvent(product: product, quantity: quantity),
                );

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${product.name} to cart'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
