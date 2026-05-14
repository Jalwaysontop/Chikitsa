import 'dart:ui';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../proto/abha.pb.dart';

class AbhaCardWidget extends StatelessWidget {
  final AbhaProfile profile;

  const AbhaCardWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha:0.2),
                Colors.white.withValues(alpha:0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha:0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.1),
                blurRadius: 10,
                spreadRadius: -2,
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ABHA Health Card',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Icon(
                    Icons.security,
                    color: Colors.greenAccent,
                    size: 28,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  // Profile Photo
                  if (profile.photoWebp.isNotEmpty)
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white54, width: 2),
                        image: DecorationImage(
                          image: MemoryImage(Uint8List.fromList(profile.photoWebp)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha:0.15),
                        border: Border.all(color: Colors.white54, width: 2),
                      ),
                      child: const Icon(Icons.person, size: 40, color: Colors.white70),
                    ),
                  
                  const SizedBox(width: 20),
                  
                  // ABHA Profile Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name.isNotEmpty ? profile.name : 'Unknown User',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withValues(alpha:0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            profile.abhaId,
                            style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${profile.gender.isNotEmpty ? profile.gender : 'U'} | DOB: ${profile.dateOfBirth}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha:0.85),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
