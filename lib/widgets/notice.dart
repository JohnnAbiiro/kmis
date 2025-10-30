import 'package:flutter/material.dart';

class NoticeBoard extends StatelessWidget {
  final double cwidth;
  const NoticeBoard({super.key, required this.cwidth});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: cwidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Notice Board',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Icon(Icons.more_vert, color: Colors.grey),
            ],
          ),
          const SizedBox(height: 10),


          Expanded(
            child: ListView(
              children: const [
                NoticeItem(
                  date: '18 Sep, 2022',
                  title: 'It is a long established fact that a reader',
                  author: 'Abiiro John',
                  timeAgo: '5 min ago',
                ),
                NoticeItem(
                  date: '18 Sep, 2022',
                  title: 'The point of using Lorem Ipsum',
                  author: 'Kolog John',
                  timeAgo: '10 min ago',
                ),
                NoticeItem(
                  date: '18 Sep, 2022',
                  title: 'Many desktop publishing packages and web',
                  author: 'Yinbey Joe',
                  timeAgo: '25 min ago',
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Clear All',
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  'Add Notice',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NoticeItem extends StatelessWidget {
  final String date;
  final String title;
  final String author;
  final String timeAgo;

  const NoticeItem({
    super.key,
    required this.date,
    required this.title,
    required this.author,
    required this.timeAgo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              date,
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Title
          Text(
            title,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 4),

          // Author + Time
          Row(
            children: [
              Text(
                author,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.access_time, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                timeAgo,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
