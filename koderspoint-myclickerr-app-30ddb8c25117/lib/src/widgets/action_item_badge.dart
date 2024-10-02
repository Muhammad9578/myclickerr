import 'package:flutter/material.dart';

class ActionItemBadge extends StatelessWidget {
  final int count;
  final Color badgeColor;
  final Color iconColor;
  final Color badgeTextColor;
  final IconData icon;
  final void Function() onTap;

  const ActionItemBadge({
    required this.count,
    required this.iconColor,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.icon,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(100),
      onTap: onTap,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 9.0, left: 9, top: 18),
            child: Icon(
              icon,
              size: 25,
              color: iconColor,
            ),
          ),
          Visibility(
            visible: count > 0,
            child: Positioned(
              top: 8,
              right: 11,
              child: CircleAvatar(
                radius: 9,
                backgroundColor: Colors.red.shade800,
                child: FittedBox(
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: TextStyle(color: badgeTextColor, fontSize: 12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
