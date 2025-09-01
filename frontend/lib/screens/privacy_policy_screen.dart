import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.purple.shade600,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Datenschutzerklärung',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Stand: 29. August 2025',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'With the following privacy policy, we would like to inform you about what types of your personal data (hereinafter also referred to as "data") we process for what purposes and to what extent. The privacy policy applies to all processing of personal data carried out by us, both in the context of providing our services and especially on our websites, in mobile applications and within external online presences, such as our social media profiles.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '1. Responsible Party',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Bashistha Joshi\nLodyweg 1A\n30167, Hannover\n\nE-Mail: master.yourself.ai@gmail.com',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '2. Overview of Processing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'The following overview summarizes the types of data processed and the purposes of their processing and refers to the data subjects.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Types of data processed:\n• Inventory data\n• Payment data\n• Contact data\n• Content data\n• Contract data\n• Usage data\n• Meta, communication and procedural data\n• Log data',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '3. Legal Basis',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Relevant legal bases under the GDPR:\n\n• Consent (Art. 6 para. 1 p. 1 lit. a GDPR)\n• Contract fulfillment and pre-contractual inquiries (Art. 6 para. 1 p. 1 lit. b GDPR)\n• Legal obligation (Art. 6 para. 1 p. 1 lit. c GDPR)\n• Legitimate interests (Art. 6 para. 1 p. 1 lit. f GDPR)',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '4. Security Measures',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We take appropriate technical and organizational measures in accordance with legal requirements, taking into account the state of the art, implementation costs and the nature, scope, circumstances and purposes of processing, as well as the different probabilities of occurrence and the extent of the threat to the rights and freedoms of natural persons, to ensure a level of protection appropriate to the risk.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '5. Data Transfer',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'In the course of our processing of personal data, it may happen that this data is transferred to other locations, companies, legally independent organizational units or persons or disclosed to them. Recipients of this data may include, for example, service providers commissioned with IT tasks or providers of services and content that are integrated into a website.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '6. International Data Transfers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'If we transfer data to a third country (i.e., outside the European Union (EU) or the European Economic Area (EEA)), this is always done in accordance with legal requirements. For data transfers to the USA, we rely on the Data Privacy Framework (DPF) and standard contractual clauses.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '7. Data Storage and Deletion',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We delete personal data that we process in accordance with legal requirements as soon as the underlying consents are revoked or there are no further legal bases for processing. Data that must be retained for commercial or tax law reasons or whose storage is necessary for legal prosecution or to protect the rights of other natural or legal persons must be archived accordingly.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '8. Your Rights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'As a data subject, you have various rights under the GDPR:\n\n• Right to object\n• Right to withdraw consent\n• Right to information\n• Right to rectification\n• Right to deletion and restriction of processing\n• Right to data portability\n• Right to lodge a complaint with a supervisory authority',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '9. Business Services',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We process data from our contractual and business partners, such as customers and interested parties, in the context of contractual and comparable legal relationships as well as associated measures and in view of communication with the contractual partners.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '10. Payment Procedures',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We offer efficient and secure payment options to the persons concerned and use banks, credit institutions and other service providers for this purpose. The data processed by payment service providers includes inventory data, payment data, contract data and usage data.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '11. Online Services and Web Hosting',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We process user data to provide them with our online services. For this purpose, we process the user\'s IP address, which is necessary to transmit the content and functions of our online services to the user\'s browser or device.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '12. Use of Cookies',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We use cookies in accordance with legal requirements. If consent is required, we obtain it in advance. If consent is not necessary, we rely on our legitimate interests. Users can revoke their consent at any time.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '13. Registration and User Accounts',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Users can create a user account. During registration, users are informed of the required mandatory information and this is processed for the purpose of providing the user account based on contractual obligation fulfillment.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '14. Single Sign-On',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We use single sign-on procedures that allow users to log in to our online offering using their user account with a single sign-on provider. This includes Google Sign-In, Apple Sign-On, and Microsoft Sign-On.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '15. Contact Management',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'When contacting us, the information of the inquiring persons is processed to the extent necessary to answer the contact inquiries and any requested measures.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '16. Push Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'With the consent of users, we can send them so-called "push notifications". These are messages that are displayed on the screens, devices or browsers of users, even when our online service is not actively being used.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '17. Newsletter and Electronic Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We send newsletters, emails and other electronic notifications exclusively with the consent of the recipients or on the basis of a legal basis. The contents of the newsletter are decisive for the consent of the users.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '18. Web Analytics and Optimization',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We use web analytics to evaluate visitor flows and optimize our online offering. This includes Google Analytics for measuring and analyzing usage based on pseudonymous user identification.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '19. Online Marketing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We process personal data for online marketing purposes, including the placement of advertising space and the display of advertising content based on potential user interests. We use Google Ads and other marketing services.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 20),
            Text(
              '20. Changes and Updates',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'We may update this privacy policy from time to time to reflect changes in our practices or for other operational, legal or regulatory reasons. We will notify you of any material changes.',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade600,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'If you have any questions about this Privacy Policy or our data practices, please contact us at:\n\nmaster.yourself.ai@gmail.com',
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
