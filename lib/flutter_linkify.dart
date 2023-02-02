import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';

export 'package:linkify/linkify.dart'
    show
        LinkifyElement,
        LinkifyOptions,
        LinkableElement,
        TextElement,
        Linkifier,
        UrlElement,
        UrlLinkifier,
        EmailElement,
        EmailLinkifier;

final userTagRegex = RegExp(
  r'^(.*?)(?<![\w@])@([\w@]+(?:[.!][\w@]+)*)',
  caseSensitive: false,
  dotAll: true,
);

class UserTagLinkifier extends Linkifier {
  const UserTagLinkifier();

  @override
  List<LinkifyElement> parse(elements, options) {
    final list = <LinkifyElement>[];

    elements.forEach((element) {
      if (element is TextElement) {
        final match = userTagRegex.firstMatch(element.text);

        if (match == null) {
          list.add(element);
        } else {
          final text = element.text.replaceFirst(match.group(0)!, '');

          if (match.group(1)?.isNotEmpty == true) {
            list.add(TextElement(match.group(1)!));
          }

          if (match.group(2)?.isNotEmpty == true) {
            list.add(UserTagElement('@${match.group(2)!}'));
          }

          if (text.isNotEmpty) {
            list.addAll(parse([TextElement(text)], options));
          }
        }
      } else {
        list.add(element);
      }
    });

    return list;
  }
}

/// Represents an element containing an user tag
class UserTagElement extends LinkableElement {
  final String userTag;

  UserTagElement(this.userTag) : super(userTag, userTag);

  @override
  String toString() {
    return "UserTagElement: '$userTag' ($text)";
  }

  @override
  bool operator ==(other) => equals(other);

  @override
  bool equals(other) =>
      other is UserTagElement &&
      super.equals(other) &&
      other.userTag == userTag;
}

/// Callback clicked link
typedef LinkCallback = void Function(LinkableElement link);

/// Turns URLs into links
class Linkify extends StatelessWidget {
  /// Text to be linkified
  final String text;

  /// Linkifiers to be used for linkify
  final List<Linkifier> linkifiers;

  /// Callback for tapping a link
  final LinkCallback? onOpen;

  /// linkify's options.
  final LinkifyOptions options;

  // TextSpan

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  /// Style of tag text
  final TextStyle? tagStyle;

  // Text.rich

  /// How the text should be aligned horizontally.
  final TextAlign textAlign;

  /// Text direction of the text
  final TextDirection? textDirection;

  /// The maximum number of lines for the text to span, wrapping if necessary
  final int? maxLines;

  /// How visual overflow should be handled.
  final TextOverflow overflow;

  /// The number of font pixels for each logical pixel
  final double textScaleFactor;

  /// Whether the text should break at soft line breaks.
  final bool softWrap;

  /// The strut style used for the vertical layout
  final StrutStyle? strutStyle;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale
  final Locale? locale;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis textWidthBasis;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the first line and descent of the last line.
  final TextHeightBehavior? textHeightBehavior;

  const Linkify({
    Key? key,
    required this.text,
    this.linkifiers = defaultLinkifiers,
    this.onOpen,
    this.options = const LinkifyOptions(),
    // TextSpan
    this.style,
    this.linkStyle,
    this.tagStyle,
    // RichText
    this.textAlign = TextAlign.start,
    this.textDirection,
    this.maxLines,
    this.overflow = TextOverflow.clip,
    this.textScaleFactor = 1.0,
    this.softWrap = true,
    this.strutStyle,
    this.locale,
    this.textWidthBasis = TextWidthBasis.parent,
    this.textHeightBehavior,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final elements = linkify(
      text,
      options: options,
      linkifiers: linkifiers,
    );

    return Text.rich(
      buildTextSpan(
        elements,
        style: Theme.of(context).textTheme.bodyText2?.merge(style),
        onOpen: onOpen,
        tagStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(style)
            .copyWith(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        )
            .merge(tagStyle),
        useMouseRegion: true,
        linkStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(style)
            .copyWith(
              color: Colors.blueAccent,
              decoration: TextDecoration.underline,
            )
            .merge(linkStyle),
      ),
      textAlign: textAlign,
      textDirection: textDirection,
      maxLines: maxLines,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      softWrap: softWrap,
      strutStyle: strutStyle,
      locale: locale,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
    );
  }
}

/// Turns URLs into links
class SelectableLinkify extends StatefulWidget {
  /// Text to be linkified
  final String text;

  /// The number of font pixels for each logical pixel
  final textScaleFactor;

  /// Linkifiers to be used for linkify
  final List<Linkifier> linkifiers;

  /// Callback for tapping a link
  final LinkCallback? onOpen;

  /// linkify's options.
  final LinkifyOptions options;

  // TextSpan

  /// Style for non-link text
  final TextStyle? style;

  /// Style of link text
  final TextStyle? linkStyle;

  /// Style of tag text
  final TextStyle? tagStyle;

  /// Style of Read more tex
  final TextStyle? readMoreStyle;

  // Text.rich

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Text direction of the text
  final TextDirection? textDirection;

  /// The minimum number of lines to occupy when the content spans fewer lines.
  final int? minLines;

  /// The maximum number of lines for the text to span, wrapping if necessary
  final int? maxLines;

  /// The strut style used for the vertical layout
  final StrutStyle? strutStyle;

  /// Defines how to measure the width of the rendered text.
  final TextWidthBasis? textWidthBasis;

  // SelectableText.rich

  /// Defines the focus for this widget.
  final FocusNode? focusNode;

  /// Whether to show cursor
  final bool showCursor;

  /// Whether this text field should focus itself if nothing else is already focused.
  final bool autofocus;

  /// Configuration of toolbar options
  final ToolbarOptions? toolbarOptions;

  /// How thick the cursor will be
  final double cursorWidth;

  /// How rounded the corners of the cursor should be
  final Radius? cursorRadius;

  /// The color to use when painting the cursor
  final Color? cursorColor;

  /// Determines the way that drag start behavior is handled
  final DragStartBehavior dragStartBehavior;

  /// If true, then long-pressing this TextField will select text and show the cut/copy/paste menu,
  /// and tapping will move the text caret
  final bool enableInteractiveSelection;

  /// Called when the user taps on this selectable text (not link)
  final GestureTapCallback? onTap;

  final ScrollPhysics? scrollPhysics;

  /// Defines how the paragraph will apply TextStyle.height to the ascent of the first line and descent of the last line.
  final TextHeightBehavior? textHeightBehavior;

  /// How tall the cursor will be.
  final double? cursorHeight;

  /// Optional delegate for building the text selection handles and toolbar.
  final TextSelectionControls? selectionControls;

  /// Called when the user changes the selection of text (including the cursor location).
  final SelectionChangedCallback? onSelectionChanged;


  final double maxWidth;

  final int trimLines;
  



  const SelectableLinkify({
    Key? key,
    required this.text,
    this.linkifiers = defaultLinkifiers,
    this.onOpen,
    this.options = const LinkifyOptions(),
    // TextSpan
    this.style,
    this.linkStyle,
    this.tagStyle,
    this.trimLines = 11,
    this.readMoreStyle,
    // RichText
    this.textAlign,
    this.maxWidth = 220,
    this.textDirection,
    this.minLines,
    this.maxLines,
    // SelectableText
    this.focusNode,
    this.textScaleFactor = 1.0,
    this.strutStyle,
    this.showCursor = false,
    this.autofocus = false,
    this.toolbarOptions,
    this.cursorWidth = 2.0,
    this.cursorRadius,
    this.cursorColor,
    this.dragStartBehavior = DragStartBehavior.start,
    this.enableInteractiveSelection = true,
    this.onTap,
    this.scrollPhysics,
    this.textWidthBasis,

    this.textHeightBehavior,
    this.cursorHeight,
    this.selectionControls,
    this.onSelectionChanged,
  }) : super(key: key);

  @override
  State<SelectableLinkify> createState() => _SelectableLinkifyState();
}

class _SelectableLinkifyState extends State<SelectableLinkify> {
   final String _kEllipsis = '\u2026';

   final String _kLineSeparator = '\u2028';
  late int maxLines, minLines;
  bool _readMore = true;


  @override
  void initState() {
    maxLines = widget.maxLines ?? 11;
    minLines = widget.minLines ?? 11;
    final elements = linkify(
      widget.text,
      options: widget.options,
      linkifiers: widget.linkifiers,
    );


    super.initState();
  }


   void _onTapLink() {
     setState(() {
       _readMore = !_readMore;
       // widget.callback?.call(_readMore);
     });
   }


   @override
  Widget build(BuildContext context) {
    final elements = linkify(
      widget.text,
      options: widget.options,
      linkifiers: widget.linkifiers,
    );

    var link = TextSpan(
      text: _readMore ? '  Read more' : '',
      style: widget.readMoreStyle,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );
    var _delimiter = TextSpan(
      text: _readMore
          ? _kEllipsis
          : '',
      style: widget.style,
      recognizer: TapGestureRecognizer()..onTap = _onTapLink,
    );

    final maxWidth = widget.maxWidth;

    var text = buildTextSpan(
          elements,
          style: Theme.of(context).textTheme.bodyText2?.merge(widget.style),
          onOpen: widget.onOpen,
          tagStyle: Theme.of(context)
              .textTheme
              .bodyText2
              ?.merge(widget.style)
              .copyWith(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          )
              .merge(widget.tagStyle),
          linkStyle: Theme.of(context)
              .textTheme
              .bodyText2
              ?.merge(widget.style)
              .copyWith(
            color: Colors.blueAccent,
            decoration: TextDecoration.underline,
          )
              .merge(widget.linkStyle),
        );

    var textPainter = TextPainter(
      text: link,
      textAlign: widget.textAlign ?? TextAlign.left,
      textDirection: widget.textDirection ?? TextDirection.ltr,
      textScaleFactor: widget.textScaleFactor,
      maxLines: widget.trimLines,
      ellipsis: widget.style?.overflow == TextOverflow.ellipsis ? _kEllipsis : null,
      // locale: widget,
    );
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final linkSize = textPainter.size;

    // Layout and measure delimiter
    textPainter.text = _delimiter;
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final delimiterSize = textPainter.size;

    // Layout and measure text
    textPainter.text = text;

    /// modified minWidth to 0
    textPainter.layout(minWidth: 0, maxWidth: maxWidth);
    final textSize = textPainter.size;

    // Get the endIndex of data
    bool linkLongerThanLine = false;
    int endIndex;

    if (linkSize.width < maxWidth) {
      final readMoreSize = linkSize.width + delimiterSize.width;
      final pos = textPainter.getPositionForOffset(Offset(
        widget.textDirection == TextDirection.rtl
            ? readMoreSize
            : textSize.width - readMoreSize,
        textSize.height,
      ));
      endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
    } else {
      var pos = textPainter.getPositionForOffset(
        textSize.bottomLeft(Offset.zero),
      );
      endIndex = pos.offset;
      linkLongerThanLine = true;
    }
    var textSpan;
    if (textPainter.didExceedMaxLines) {
      var data= _readMore
          ? widget.text.substring(0, endIndex) +
          (linkLongerThanLine ? _kLineSeparator : '')
          : widget.text;
      final elements = linkify(
        data,
        options: widget.options,
        linkifiers: widget.linkifiers,
      );

      textSpan = buildTextSpan(
        elements,
        style: Theme.of(context).textTheme.bodyText2?.merge(widget.style),
        onOpen: widget.onOpen,
        tagStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(widget.style)
            .copyWith(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        )
            .merge(widget.tagStyle),
        linkStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(widget.style)
            .copyWith(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        )
            .merge(widget.linkStyle),
        children: [_delimiter, link],

        // useMouseRegion: widget.,
      );
    } else {
      var data= widget.text;
      final elements = linkify(
        data,
        options: widget.options,
        linkifiers: widget.linkifiers,
      );

      textSpan = buildTextSpan(
        elements,
        style: Theme.of(context).textTheme.bodyText2?.merge(widget.style),
        onOpen: widget.onOpen,
        tagStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(widget.style)
            .copyWith(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        )
            .merge(widget.tagStyle),
        linkStyle: Theme.of(context)
            .textTheme
            .bodyText2
            ?.merge(widget.style)
            .copyWith(
          color: Colors.blueAccent,
          decoration: TextDecoration.underline,
        )
            .merge(widget.linkStyle),
        children: [],

        // useMouseRegion: widget.,
      );
    }

        return SelectableText.rich(
          textSpan,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          focusNode: widget.focusNode,
          strutStyle: widget.strutStyle,
          showCursor: widget.showCursor,
          textScaleFactor: widget.textScaleFactor,
          autofocus: widget.autofocus,
          toolbarOptions: widget.toolbarOptions,
          cursorWidth: widget.cursorWidth,
          cursorRadius: widget.cursorRadius,
          cursorColor: widget.cursorColor,
          dragStartBehavior: widget.dragStartBehavior,
          enableInteractiveSelection: widget.enableInteractiveSelection,
          onTap: widget.onTap,
          scrollPhysics: widget.scrollPhysics,
          textWidthBasis: widget.textWidthBasis,
          textHeightBehavior: widget.textHeightBehavior,
          cursorHeight: widget.cursorHeight,
          selectionControls: widget.selectionControls,
          onSelectionChanged: widget.onSelectionChanged,
        );

  }

}

class LinkableSpan extends WidgetSpan {
  LinkableSpan({
    required MouseCursor mouseCursor,
    required InlineSpan inlineSpan,
  }) : super(
          child: MouseRegion(
            cursor: mouseCursor,
            child: Text.rich(
              inlineSpan,
            ),
          ),
        );
}

/// Raw TextSpan builder for more control on the RichText
TextSpan buildTextSpan(
  List<LinkifyElement> elements, {
  TextStyle? style,
  TextStyle? linkStyle,
  TextStyle? tagStyle,
  LinkCallback? onOpen,
  bool useMouseRegion = false, List<TextSpan> children= const [],
}) {
  return TextSpan(

    children: elements.map<InlineSpan>(
      (element) {
        if (element is LinkableElement) {
          if (useMouseRegion) {
            return LinkableSpan(
              mouseCursor: SystemMouseCursors.click,
              inlineSpan: TextSpan(
                text: element.text,
                style: element is UserTagElement
                    ? tagStyle ?? linkStyle
                    : linkStyle,
                recognizer: onOpen != null
                    ? (TapGestureRecognizer()..onTap = () => onOpen(element))
                    : null,
              ),
            );
          } else {
            return TextSpan(
              text: element.text,
              style: element is UserTagElement
                  ? tagStyle ?? linkStyle
                  : linkStyle ,
              recognizer: onOpen != null
                  ? (TapGestureRecognizer()..onTap = () => onOpen(element))
                  : null,
            );
          }
        } else {
          return TextSpan(
            text: element.text,
            style: style,
          );
        }
      },
    ).toList()..addAll(children),
  );
}
