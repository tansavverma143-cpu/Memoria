import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:memoria/constants/constants.dart';

class EULAScreen extends StatelessWidget {
  const EULAScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('End User License Agreement'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const WebView(
        initialUrl: 'https://mymemoria.tech/eula',
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}

// Local EULA content (fallback if webview fails)
const String eulaContent = '''
END USER LICENSE AGREEMENT (EULA)

Last Updated: January 1, 2024

1. AGREEMENT TO TERMS
This End User License Agreement ("Agreement") is a binding agreement between you ("End User" or "you") and MEMORIA ("Company," "we," "us," or "our"). This Agreement governs your use of the MEMORIA mobile application (the "Application").

By downloading, installing, or using the Application, you:
(a) Acknowledge that you have read and understand this Agreement;
(b) Represent that you are of legal age to enter into a binding agreement; and
(c) Accept this Agreement and agree that you are legally bound by its terms.

2. LICENSE GRANT
Subject to the terms of this Agreement, Company grants you a limited, non-exclusive, non-transferable, non-sublicensable, revocable license to:
(a) Download, install, and use the Application for your personal, non-commercial use on a single mobile device owned or otherwise controlled by you ("Mobile Device") strictly in accordance with the Application's documentation; and
(b) Access, stream, download, and use on such Mobile Device the Content and Services (as defined in Section 5) made available in or otherwise accessible through the Application.

3. LICENSE RESTRICTIONS
You shall not:
(a) Copy the Application, except as expressly permitted by this license;
(b) Modify, translate, adapt, or otherwise create derivative works or improvements, whether or not patentable, of the Application;
(c) Reverse engineer, disassemble, decompile, decode, or otherwise attempt to derive or gain access to the source code of the Application or any part thereof;
(d) Remove, delete, alter, or obscure any trademarks or any copyright, trademark, patent, or other intellectual property or proprietary rights notices from the Application;
(e) Rent, lease, lend, sell, sublicense, assign, distribute, publish, transfer, or otherwise make available the Application or any features or functionality of the Application to any third party;
(f) Use the Application in any manner that could interfere with, disrupt, negatively affect, or inhibit other users from fully enjoying the Application;
(g) Use the Application for any illegal, unauthorized, or unethical purpose;
(h) Attempt to bypass any security features of the Application;
(i) Use any robot, spider, crawler, scraper, or other automated means or interface not provided by us to access the Application;
(j) Use the Application to develop a competing product or service.

4. SUBSCRIPTION AND PAYMENTS
4.1 Subscription Plans: The Application offers various subscription plans as described in the Application. Subscription fees are billed in advance on a periodic basis as specified in the Application.
4.2 Auto-Renewal: Subscriptions automatically renew unless auto-renew is turned off at least 24 hours before the end of the current period.
4.3 Cancellation: You can cancel your subscription at any time through your device's subscription settings.
4.4 Refunds: All payments are non-refundable except as required by law or as otherwise specifically permitted in our Refund Policy.

5. USER CONTENT
5.1 Ownership: You retain all rights to your content. You grant us a non-exclusive, worldwide, royalty-free license to use, store, and display your content solely to provide the Services to you.
5.2 Responsibility: You are solely responsible for your content and the consequences of posting or publishing it.
5.3 Prohibited Content: You agree not to upload content that:
   (a) Infringes any third party's intellectual property rights;
   (b) Contains viruses or malicious code;
   (c) Is illegal, defamatory, obscene, or offensive;
   (d) Violates anyone's privacy or publicity rights.

6. PRIVACY POLICY
We respect your privacy and are committed to protecting it through our compliance with our Privacy Policy. Please review our Privacy Policy, which also governs your use of the Application.

7. GEOGRAPHIC RESTRICTIONS
The Application is intended for use only in jurisdictions where it may be lawfully offered for use. We make no claims that the Application or any of its content is accessible or appropriate outside of supported jurisdictions.

8. TERM AND TERMINATION
8.1 Term: The term of this Agreement commences when you download/install the Application and will continue in effect until terminated by you or Company.
8.2 Termination by You: You may delete the Application and all copies thereof from your Mobile Device.
8.3 Termination by Company: We may terminate this Agreement at any time without notice if you fail to comply with any term hereof.
8.4 Effect of Termination: Upon termination, all rights granted to you under this Agreement will also terminate.

9. DISCLAIMER OF WARRANTIES
THE APPLICATION IS PROVIDED TO YOU "AS IS" AND WITH ALL FAULTS AND DEFECTS WITHOUT WARRANTY OF ANY KIND. TO THE MAXIMUM EXTENT PERMITTED UNDER APPLICABLE LAW, COMPANY EXPRESSLY DISCLAIMS ALL WARRANTIES, WHETHER EXPRESS, IMPLIED, STATUTORY, OR OTHERWISE.

10. LIMITATION OF LIABILITY
TO THE FULLEST EXTENT PERMITTED BY APPLICABLE LAW, IN NO EVENT WILL COMPANY BE LIABLE FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES.

11. INDEMNIFICATION
You agree to indemnify, defend, and hold harmless Company from any claims, liabilities, damages, judgments, awards, losses, costs, expenses, or fees arising out of or relating to your violation of this Agreement.

12. GOVERNING LAW
This Agreement shall be governed by and construed in accordance with the laws of the State of California, without regard to its conflict of law principles.

13. SEVERABILITY
If any provision of this Agreement is illegal or unenforceable under applicable law, the remainder of the provision will be amended to achieve as closely as possible the effect of the original term.

14. ENTIRE AGREEMENT
This Agreement constitutes the entire agreement between you and Company regarding the Application and supersedes all prior agreements.

15. CONTACT INFORMATION
For questions about this EULA, contact us at: legal@mymemoria.tech
''';