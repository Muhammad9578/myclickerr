
import '../models/on_boarding_model.dart';
import 'constants.dart';



//********************************************************
List<OnBoardingContent> PhotographerOnboardingList() {
  return [
    OnBoardingContent(
        message: 'Upload your work and get exposure',
        img: ImageAsset.Onboard1Image,
        description:
            'Showcase your work to millions of customers who are looking for photography services. Maintaining a good profile is the key to unlock more clients.'),
    OnBoardingContent(
        message: 'Manage your bookings & clients',
        img: ImageAsset.Onboard2Image,
        description:
            'Stay organized, MyClickerr empowers you to manage your bookings with ease, ensuring a seamless experience for both you and your valued clients.'),
    OnBoardingContent(
        message: 'Manage your payments',
        img: ImageAsset.Onboard3Image,
        description:
            'MyClickerr allows you to easily track, process, and manage payments from your clients. Add a payout method to get paid after successfully completing an order.'),
  ];
}

List<OnBoardingContent> UserOnboardingList() {
  return [
    OnBoardingContent(
        message: 'Hire the best photographers in the city',
        img: ImageAsset.Onboard1Image,
        description:
            'All the photographers on our platform are highly experienced in their category & Onborded only after several quality checks.'),
    OnBoardingContent(
        message: 'Flexible hourly rates',
        img: ImageAsset.Onboard2Image,
        description:
            "Book the best photographers in your budget. Whether it's a special event, a family gathering, or a personal photoshoot, our talented photographers are ready to work for you."),
    OnBoardingContent(
        message: 'Book & Relax',
        img: ImageAsset.Onboard3Image,
        description:
            'We stay connected with the photographer until your needs and booking are successfully completed. Photographer gets paid only after fulfilling the shoot needs.'),
  ];
}
