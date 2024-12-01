import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/models/vietmap_autocomplete_model.dart';
import '../../map_screen/bloc/map_bloc.dart';
import '../../map_screen/bloc/map_event.dart';

class ItemWithEntryPoints extends StatelessWidget {
  const ItemWithEntryPoints({super.key, required this.model});
  final VietmapAutocompleteModel model;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      shape: const Border(),
      initiallyExpanded: true,
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.only(left: 30),
      title: InkWell(
        onTap: () {
          context.read<MapBloc>().add(MapEventGetDetailAddress(model));
          FocusScope.of(context).requestFocus(FocusNode());
          Navigator.pop(context);
        },
        child: Row(
          children: [
            const SizedBox(width: 10),
            const Icon(Icons.location_pin, color: Colors.black54),
            const SizedBox(width: 5),
            Expanded(
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(model.name ?? ''),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Text(model.address ?? ''), const Divider()],
                ),
              ),
            ),
          ],
        ),
      ),
      children: [
        for (var entryPoint in model.entryPoint!)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  context.read<MapBloc>().add(
                      MapEventGetEntryPointDetailAddress(entryPoint.refId!));
                  FocusScope.of(context).requestFocus(FocusNode());
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    const Icon(Icons.door_sliding_sharp, color: Colors.black54),
                    const SizedBox(width: 5),
                    Expanded(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          entryPoint!.display ?? '',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                indent: 30,
                endIndent: 20,
              ),
            ],
          ),
      ],
    );
  }
}
