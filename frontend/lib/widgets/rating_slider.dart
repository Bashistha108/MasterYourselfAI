import 'package:flutter/material.dart';

class RatingSlider extends StatefulWidget {
  final double initialValue;
  final Function(double) onChanged;
  final Function(double) onChangedEnd;

  const RatingSlider({
    Key? key,
    required this.initialValue,
    required this.onChanged,
    required this.onChangedEnd,
  }) : super(key: key);

  @override
  _RatingSliderState createState() => _RatingSliderState();
}

class _RatingSliderState extends State<RatingSlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
  }

  Color _getColor(double value) {
    if (value <= 3) return Colors.red;
    if (value <= 7) return Colors.orange;
    return Colors.green;
  }

  String _getLabel(double value) {
    if (value <= 3) return 'Poor';
    if (value <= 7) return 'Good';
    return 'Excellent';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Rating: ${_value.toInt()}/10',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: _getColor(_value),
              ),
            ),
            Text(
              _getLabel(_value),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getColor(_value),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getColor(_value),
            inactiveTrackColor: Colors.grey[300],
            thumbColor: _getColor(_value),
            overlayColor: _getColor(_value).withOpacity(0.2),
            trackHeight: 6,
            thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _value,
            min: 0,
            max: 10,
            divisions: 10,
            onChanged: (newValue) {
              setState(() {
                _value = newValue;
              });
              widget.onChanged(newValue);
            },
            onChangeEnd: (newValue) {
              widget.onChangedEnd(newValue);
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            Text(
              '10',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
