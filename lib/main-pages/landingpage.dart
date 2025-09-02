import 'package:caffe_pandawa/customer/qr_scanner_screen.dart';
import 'package:caffe_pandawa/main-pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Landingpage extends StatefulWidget {
  @override
  _LandingpageState createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatingController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _floatingController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _floatingAnimation = Tween<double>(
      begin: -10.0,
      end: 10.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _startScan() async {
    setState(() {
      _isScanning = true;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    setState(() {
      _isScanning = false;
    });

    // Show dialog or navigate to scanner
    _showScannerDialog();
  }

  void _showScannerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.qr_code_scanner, color: Color(0xFF8B4513)),
              SizedBox(width: 8),
              Text('Scanner Menu'),
            ],
          ),
          content: Text(
            'Scanner akan terbuka untuk memindai QR code menu.\n\nPastikan kamera memiliki akses dan QR code terlihat jelas.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Di sini akan membuka scanner QR code
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QrScannerScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF8B4513),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Buka Scanner',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => Login(),
                ),
              );
            },
            child: Text(
              'Login',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.brown,
              const Color.fromARGB(255, 129, 93, 80),
              const Color.fromARGB(255, 128, 98, 87),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(),
                _buildMainContent(),
                SizedBox(height: 100), // Space for bottom navigation
              ],
            ),
          ),
        ),
      ),
      // bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          // Logo with pulse animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu,
                    size: 36,
                    color: Color(0xFFFFF8DC),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20),

          // App Name
          Text(
            'ScanDine',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Color(0xFFFFF8DC),
              letterSpacing: 1,
              shadows: [
                Shadow(
                  offset: Offset(2, 2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.3),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),

          // Tagline
          Text(
            'Pesan Menu dengan Sekali Scan',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFFFFF8DC).withOpacity(0.9),
              fontWeight: FontWeight.w300,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 2,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          // Welcome Card
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 32,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Selamat datang di masa depan pemesanan makanan!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFFFFF8DC),
                    height: 1.6,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                SizedBox(height: 30),

                // Scan Button
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _startScan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isScanning
                          ? Colors.green
                          : const Color.fromARGB(255, 108, 74, 62),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 18,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 6,
                      shadowColor: Colors.brown.withOpacity(0.3),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _isScanning
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(Icons.qr_code_scanner, size: 20),
                        SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            _isScanning ? 'MEMBUKA SCANNER...' : 'SCAN MENU',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 30),

          // Features Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
            children: [
              _buildFeatureCard(
                Icons.flash_on,
                'Cepat & Mudah',
                'Scan QR code dan pesan dalam hitungan detik',
              ),
              _buildFeatureCard(
                Icons.phone_android,
                'Tanpa Antri',
                'Langsung pesan dari meja tanpa menunggu pelayan',
              ),
              _buildFeatureCard(
                Icons.payment,
                'Pembayaran Digital',
                'Bayar dengan e-wallet atau kartu kredit',
              ),
              _buildFeatureCard(
                Icons.star,
                'Menu Terbaru',
                'Selalu update dengan menu dan promo terkini',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return AnimatedBuilder(
      animation: _floatingAnimation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _floatingAnimation.value),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.1),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Color(0xFFFFE4B5),
                ),
                SizedBox(height: 10),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFFFF8DC),
                  ),
                ),
                SizedBox(height: 5),
                Expanded(
                  child: Text(
                    description,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFF8DC).withOpacity(0.8),
                      height: 1.3,
                    ),
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
