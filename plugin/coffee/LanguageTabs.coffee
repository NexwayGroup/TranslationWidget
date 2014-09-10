#
# @author   Michal Katanski (mkatanski@nexway.com)
# @author   Ariana Las <ariana.las@gmail.com>
# @author   Mariusz Maroń <mmaron@nexway.com>
# @author   Damian Duda <dduda@nexway.com>
# @version 1.0.1
class LanguageTabs

  HIGHLIGHT_COLOR =   '#ffb848'
  MOUSE_OVER_COLOR =  '#e1e1e1'
  BASE_COLOR =        '#eee'

  constructor: (@base) ->
    @buttons = []

    @base.log 'Language tabs created'
    @_render()
    @_addCustomAnimation()

    #Get original width of base input
    @baseInputWidth = parseInt @base.baseElement.find('.lang-translation').width()
    return

  _render: ->
    ltHTML = '''
    <div class="language-tabs"></div>
    '''
    $(ltHTML).insertAfter @base.baseElement.find '.translation-options'
    @_currentElement = @base.baseElement.find '.language-tabs'
    @base.log 'Language tabs rendered'


  addButton: (langCode) ->
    if @buttonExists langCode
      @base.log "Cannot add [#{langCode}]! Button exists."
      return

    span = $("<span id=\"#{langCode}\" class=\"chosen-language\"/>").text langCode
    removeIcon = $('<a href="#" class="remove icon-remove" />')
    removeIcon.appendTo span

    removeIcon.on 'click.'+@base.pluginName, (e) =>
      e.preventDefault()
      e.stopPropagation()
      @base.showConfirmBox =>
        @base.edWindow.removeLang langCode
        @base.edWindow.hide()
        # finally remove button from document
        @removeButton langCode
        return

    # Add onClick event for button to show editor window in edit mode
    # or hide it when its already opened
    span.on 'click.'+@base.pluginName, =>
      @base.log "LangBtn [#{langCode}] clicked"
      @base.edWindow.show langCode

    # add mouse events for highlighting item
    span.on 'mouseover.'+@base.pluginName, =>
      span.css {backgroundColor: MOUSE_OVER_COLOR}
    span.on 'mouseleave.'+@base.pluginName, =>
      span.css {backgroundColor: BASE_COLOR}

    span.appendTo @_currentElement

    @base.log "Button added: #{langCode}"
    @_updateInputWidth()
    return

  removeButton: (langCode) ->
    @_currentElement.find('#'+langCode).remove()
    @base.log "Button [#{langCode}] removed"
    @_updateInputWidth()
    return

  buttonExists: (langCode) ->
    return if @_currentElement.find('#'+langCode).length is 1 then true else false

  highlight: (langCode) ->
    button = @_currentElement.find('#'+langCode)
    if $.isFunction @.customAnimation
        button.customAnimation()
    else
      button.css {backgroundColor: HIGHLIGHT_COLOR}
      button.animate {"backgroundColor": BASE_COLOR}, @base.options.addAnimationSpeed
    return

  _updateInputWidth: ->
    #Calculation for each languages
    btnsCount = @_currentElement.children('span').length
    btnsSpacing = btnsCount * 11
    btnsTotalWidth = @_currentElement.children('span').width() * btnsCount + btnsSpacing

    if btnsTotalWidth > @baseInputWidth
      @base.baseElement.find('.lang-translation').width btnsTotalWidth + 14
    else
      @base.baseElement.find('.lang-translation').width @baseInputWidth
    return

  _addCustomAnimation: ->
    animationNames = ["slideToggle", "fadeToggle"]

    # if custom animation is function
    if $.isFunction @base.options.addAnimation
      # set new custom animation function
      $.fn["customAnimation"] = @base.options.addAnimation;
      @base.log 'Added custom animation as new function'
    else
      # else check if name of animation is valid
      if $.inArray(@base.options.addAnimation , animationNames) isnt -1
        # set new animation based on valid animation name
        $.fn["customAnimation"] = ->
          @[@base.options.addAnimation] 0
          return @[@base.options.addAnimation] @base.options.addAnimationSpeed
        @base.log 'Added custom animation based on name'
