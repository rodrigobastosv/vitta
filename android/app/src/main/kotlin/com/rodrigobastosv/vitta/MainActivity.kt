package com.rodrigobastosv.vitta

import io.flutter.embedding.android.FlutterFragmentActivity

// FlutterFragmentActivity (not FlutterActivity) is required by the health package's
// Health Connect permission flow, which launches its request as a fragment.
class MainActivity : FlutterFragmentActivity()
