soma = require('soma')
wings = require('wings')

soma.chunks
    Code:
        meta: -> new soma.chunks.Base({ content: @ })

        prepare: ({@classId, @levelId}) ->
            @template = @loadTemplate "/build/common/templates/puzzles/code.html"
            
            @loadScript '/assets/third_party/ace/ace.js'
            @loadScript '/build/common/pages/puzzles/lib/code.js'

            @loadStylesheet '/build/client/css/puzzles/code.css'     

            if not @levelId
                @levelId = STAGES[0].levels[0].id
            
        build: ->
            @setTitle("Code Puzzles - The Puzzle School")
            
            @html = wings.renderTemplate(@template,
                level: @levelId
                stages: STAGES
            )
        
soma.views
    Code:
        selector: '#content .code'
        create: ->
            code = require('./lib/code')
            
            @originalHTML = @el.find('.dynamic_content').html()
        
            @level = @findLevel(@el.data('level'))
            
            @helper = new code.ViewHelper
                el: @el
                completeLevel: => @completeLevel()

            @helper.initLevel(@level)

            @initLevelSelector()
            @initActions()
            
        initActions: ->
            @$('.select_level').bind 'click', => @showLevelSelector()
            @$('.reset_level').bind 'click', => @initLevel()
            
        findLevel: (levelId) ->
            for stage in STAGES
                level = (level for level in stage.levels when level.id == levelId)[0]
                return level if level

        initLevel: ->
            @el.find('.dynamic_content').html(@originalHTML)
            @helper.initLevel(@level)

        initLevelSelector: ->
            @levelSelector = @$('.level_selector')
            for level in @levelSelector.find('.level')
                do (level) =>
                    level = $(level)
                    level.bind 'click', (e) => 
                        e.stop()
                        $(document.body).unbind('click.level_selector')
                        @level = @findLevel(level.data('id'))
                        @initLevel()
                        history.pushState(null, null, "/puzzles/code/#{@level.id}")
                        @hideLevelSelector()
                
        completeLevel: ->
            test.clean() for test in @level.tests when test.clean
                
            levelIcon = @$("#level_#{@level.id}").find('img')
            if levelIcon.attr('src').indexOf('complete') == -1
                levelIcon.attr('src', levelIcon.attr('src').replace('level', 'level_complete'))
            challenge = @$('.challenge')
            challenge.animate
                opacity: 0
                duration: 250
                complete: =>
                    challenge.html '''
                        <h3 class='success'>Success!</h3>
                        <a class='next_level'>Select A New Level</a>
                    '''
                    challenge.find('.next_level').bind 'click', => @showLevelSelector(true)
                    challenge.animate(opacity: 1, duration: 250)
            
        showLevelSelector: (success) ->
            if success
                @levelSelector.addClass('success') 
            else
                @levelSelector.removeClass('success') 
            
            @levelSelector.css
                opacity: 0
                top: 60
                left: (@el.width() - @levelSelector.width()) / 2
            @levelSelector.animate
                opacity: 1
                duration: 250
            
            setTimeout((=>    
                $(document.body).one 'click.level_selector', => @hideLevelSelector()
            ), 10)
                
        hideLevelSelector: ->
            @levelSelector.animate
                opacity: 0
                duration: 250
                complete: =>
                    @levelSelector.css
                        top: -1000
                        left: -1000
                            
        saveProgress: (puzzleProgress, callback) ->
            if @cookies.get('user')
                puzzleUpdates = @getUpdates(puzzleProgress)
                return unless puzzleUpdates

                levelUpdates = {}
                for languages, levels of puzzleUpdates.levels
                    for levelName, levelInfo of levels
                        levelUpdates["#{languages}/#{levelName}"] = levelInfo
                delete puzzleUpdates.levels

                $.ajaj
                    url: "/api/puzzles/code/update"
                    method: 'POST'
                    headers: { 'X-CSRF-Token': @cookies.get('_csrf', {raw: true}) }
                    data: 
                        puzzleUpdates: puzzleUpdates
                        levelUpdates: levelUpdates
                    success: => 
                        @puzzleData = JSON.parse(JSON.stringify(puzzleProgress))
                        callback() if callback

            else if puzzleProgress.levels 
                window.postRegistration.push((callback) => @saveProgress(puzzleProgress, callback))

                @answerCount = 0 if not @answerCount
                @answerCount += 1
                if @answerCount > 7
                    if @answerCount % 8 == 0
                        registrationFlag = $('.register_flag')
                        paddingTop = registrationFlag.css('paddingTop')
                        $.timeout 1000, =>
                            registrationFlag.animate
                                paddingTop: 45
                                paddingBottom: 45
                                duration: 1000
                                complete: =>
                                    $.timeout 1000, =>
                                        registrationFlag.animate
                                            paddingTop: paddingTop
                                            paddingBottom: paddingTop
                                            duration: 1000

                    $(window).bind 'beforeunload', => return 'If you leave this page you\'ll lose your progress on this level. You can save your progress above.'
            
            
soma.routes
    '/puzzles/code/:classId/:levelId': ({classId, levelId}) -> 
        new soma.chunks.Code
            classId: classId
            levelId: levelId

    '/puzzles/code/:levelId': ({levelId}) -> 
        new soma.chunks.Code
            levelId: levelId
    
    '/puzzles/code': -> new soma.chunks.Code


STAGES = [
    {
        name: 'Basic HTML'
        levels: [
            {
                id: 1361991179382
                challenge: '''
                    Figure out how to change the word "Welcome" to the word "Hello World'".
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                                <body>
                                    <h1>Welcome</h1>
                                </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        The code displayed in the 'editor' (where it says 'Page HTML') 
                        is all the code you need to create the simplest website.
                    </p>
                    <p>
                        The &lt;h1&gt; is used to designate important information and so is displayed in
                        bold large text.
                    </p>
                    <p>
                        You can learn more about the &lt;h1&gt; tag by googling:
                        <a href='https://www.google.com/search?q=h1+tag' target='_blank'>'h1 tag'</a>.
                    </p>
                '''
                hints: [
                    'The \'editor\', where you see the words \'Page HTML\' is editable.'
                    'In the editor, change the word \'Welcome\' to \'Hello World\''
                ]
                tests: [
                    {
                        description: 'The content contains an &lt;h1&gt; tag with html content \'Hello World\'.'
                        test: ({body, cleanHtml}) -> 
                            cleanHtml(body.find('h1').html()) == 'hello world'
                    }
                ]
            }, {
                id: 1361991210187
                challenge: '''
                    Figure out how to print the words 'html tags are easy' in an &lt;h1&gt; tag.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                                <body>
                                    
                                </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        Here we've removed the tag from the body of the html.
                    </p>
                    <p>
                        You simply need to put it back and don't forget to close the tag.
                    </p>
                '''
                hints: [
                    'Create a new &lt;h1&gt; tag by typing "&lt;h1&gt;" between &lt;body&gt; and &lt;/body&gt;'
                    'You need to close the &lt;h1&gt; tag with a closing tag.'
                    'The closing tag looks like &lt;/h1&gt;'
                ]
                tests: [
                    {
                        description: 'The content contains an &lt;h1&gt; tag with html content \'html tags are easy\'.'
                        test: ({body, cleanHtml}) -> 
                            cleanHtml(body.find('h1').html()) == 'html tags are easy'
                    }
                    {
                        description: 'The &lt;h1&gt; tag is properly closed.'
                        test: ({body}) -> body.html().indexOf('</h1>') > -1
                    }
                ]
            }, {
                id: 1361997759104
                challenge: '''
                    Figure out how to change the smallest text to 'this is the smallest header'.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                                <body>
                                    <h2>This is a header</h2>
                                    <h4>This is a header</h4>
                                    <h6>This is a header</h6>
                                    <h1>This is a header</h1>
                                    <h5>This is a header</h5>
                                    <h3>This is a header</h3>
                                </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        Here is a simply demo of all of the available header tags.
                    </p>
                    <p>
                        As you can see they range in size, designating the intent to show important information.
                    </p>
                '''
                hints: [
                    'The &lt;h4&gt; is smaller than the &lt;h3&gt; tag.'
                    'Change the text inside the &lt;h6&gt; tag.'
                ]
                tests: [
                    {
                        description: 'The header with the smallest text size contains the text \'this is the smallest header\'.'
                        test: ({body, cleanHtml}) -> 
                            cleanHtml(body.find('h6').html()) == 'this is the smallest header'
                    }
                ]
            }, {
                id: 1362028733004
                challenge: '''
                    Figure out how to make the text 'such as the &lt;b&gt; tag' bold using the &lt;b&gt; tag.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <h1>Playing With Tags</h1>
                                <p>
                                  The &lt;p&gt; tag is for paragraph text.
                                </p>
                                <p>
                                  If can contain other tags, such as the 
                                  &lt;b&gt; tag, which makes text bold.
                                </p>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        There are many html tags, each of which have different attributes.
                    </p>
                    <p>
                        You can find a list of availablt html tags by googling 
                        <a href='https://www.google.com/search?q=html+tags' target='_blank'>html tags</a>
                    </p>
                    <p>
                        In order to make a tag display in plain text you need to use an html character entity.
                    </p>
                    <p>
                        You can find a full list of character entitities <a href='http://www.w3schools.com/html/html_entities.asp' target='_blank'>here</a>.
                    </p>
                '''
                hints: [
                    'Wrap text in an html tag to apply the attributes of that tag.'
                    'Simply put a &lt;b&gt; before the \'such as the &lt;b&gt; tag\' text and a &lt;b&gt; after.'
                    'In the end it should look like &lt;b&gt;such as the &amp;lt;b&amp;gt; tag&lt;/b&gt; with no comma inside the tag.'                     
                ]
                tests: [
                    {
                        description: 'There is a &lt;b&gt; tag with the html \'such as the &lt;b&gt; tag\'.'
                        test: ({body, cleanHtml}) -> 
                            html = cleanHtml(body.find('b').html())
                            html == 'such as the &lt;b&gt; tag'
                    }
                ]
            }, {
                id: 1362072970429
                challenge: '''
                    Figure out how to make the header text red.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <h1 style='color: green'>Playing With Tags</h1>
                                <p>
                                  Html tags can contain attributes that modify the behavior of the tag.
                                </p>
                                <p>
                                  This is an example of an attribute modifying the tags style.
                                </p>
                                <p>
                                  The 'style' attribute with a value of 'color: green' is making the &lt;h1&gt; turn green.
                                </p>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        You can modify the attributes of a given tag by adding different attributes within the tag.
                    </p>
                '''
                hints: [
                    'Look for the word \'green\' in the html.'
                    'Change the word \'green\' to the word \'red\'.'
                ]
                tests: [
                    {
                        description: 'The &lt;h1&gt; tag has a color of red.'
                        test: ({body, cleanHtml}) -> body.find('h1').css('color') == 'red'
                    }
                ]
            }, {
                id: 1362074585433
                challenge: '''
                    Figure out how to change the link to display and direct to a new website.
                '''
                editors: [
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <h1>Linking Fun</h1>
                                <p>
                                  Anchor tags (&lt;a&gt;) can be used to place a link to another website on your page.
                                </p>
                                <p>
                                  This link goes to <a href='http://puzzleschool.com' target='_new'>The Puzzle School</a>.
                                </p>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        The anchor (&lt;a&gt;) tag allows you to jump to another anchor point.
                    </p>
                    <p>
                        The anchor point can be on the same page or a new page.
                    </p>
                    <p>
                        Anchor tags are usually used to link to another website using the 'href' attribute.
                    </p>
                '''
                hints: [
                    'The \'href\' attribute within a link (&lt;a&gt;) tag describes the destination of the link.'
                    'Change the href attribute to point to a different website besides http://puzzleschool.com'
                    'To change the title of the link, simply edit the html inside.'
                    'Change the text \'The Puzzle School\' to a different website\'s name.'
                ]
                tests: [
                    {
                        description: 'The &lt;a&gt; tag has a link to a new website.'
                        test: ({body, cleanHtml}) => 
                            link = body.find('a')                            
                            return false if link.attr('href') == 'http://puzzleschool.com'
                            return true
                    },
                    {
                        description: 'The &lt;a&gt; tag\'s html if for a different website.'
                        test: ({body, cleanHtml}) => 
                            link = body.find('a')                            
                            return false if link.html() == 'The Puzzle School'
                            return true
                    }
                ]
            }
        ]
    }
    {
        name: 'Random Javascript'
        levels: [
            {
                id: 1362424704636
                challenge: '''
                    Figure out how to make the button turn the header color green instead or red.
                '''
                editors: [
                    {
                        title: 'Page Javascript'
                        type: 'javascript'
                        code: '''
                            var button = document.getElementById('color_button');
                            button.onclick = function () {
                              var header = document.getElementById('header');
                              header.style.color = 'red';
                            };
                        '''
                    }
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <h1 id='header'>Button Binding</h1>
                                <p>
                                  Javascript lets you attach or bind actions to html elements on the page.
                                </p>
                                <p>
                                  In this case clicking the button below will turn change the color of
                                  the header from black to red.
                                </p>
                                <p>
                                  Try to make the button change the color of the header to green instead:
                                </p>
                                <button id='color_button'>Click Me</button>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        Javascript makes it possible to bind an action to an html element.
                    </p>
                    <p>
                        Binding means that a function will be executed when an action takes place.
                    </p>
                    <p>
                        In this example the color of the header changes when the button is clicked.
                    </p>
                '''
                hints: [
                    'Javascript can access the color attribute using \'.style.color\''
                    'Change the function to set .style.color to \'green\''
                ]
                tests: [
                    {
                        description: 'The color of the &lt;h2&gt; element is green.'
                        test: ({body, cleanHtml}) =>
                            if body.find('#header').css('color') == 'green'
                                clearInterval(@testInterval)
                                return true 
                                
                            return false if @testInterval
                            @testInterval = setInterval(window.retest, 100)
                            return false
                        clean: =>
                            clearInterval(@testInterval)
                            @testInterval = null
                    }
                ]
            },
            {
                id: 1362099940993
                challenge: '''
                    Figure out how to make the number on the page count up to 10.
                '''
                editors: [
                    {
                        title: 'Page Javascript'
                        type: 'javascript'
                        code: '''
                          if (window.counterInterval) {
                              window.clearInterval(window.counterInterval);
                          }
                          
                          window.counterInterval = setInterval(function() {
                            var counter = document.getElementById('counter');
                            if (!counter) return;
                                
                            var value = parseInt(counter.innerHTML);
                            value += 1;
                            if (value > 5) {
                              value = 1;
                            }
                            counter.innerHTML = value;
                            
                          }, 1000);                        
                        '''
                    }
                    {
                        title: 'Page HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <h1>setInterval</h1>
                                <p>
                                  The setInterval method allows you to call a method at a specified interval.
                                </p>
                                <p>
                                  In this case we're calling a method changes increments the counter below every second.
                                </p>
                                <p>
                                  Try to make the counter below count to 10 instead of 5:
                                </p>
                                <h2 id='counter'>1</h2>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                        There is a lot going on in this example, but we're focusing on the setInterval function.
                    </p>
                    <p>
                        To learn more about setInterval, try googling it :)
                    </p>
                '''
                hints: [
                    'The function resets when the html in the &lt;h2&gt hits 5.'
                    'Change the reset value to 10.'
                    'The reset value is set in this line: if (value > 5) {'
                    'Change the 5 in that line to 10'
                ]
                tests: [
                    {
                        description: 'The html inside the &lt;h2&gt; tag reads 10.'
                        test: ({body, cleanHtml}) => 
                            if cleanHtml(body.find('h2').html()) == '10'
                                clearInterval(@testInterval)
                                return true 
                                
                            return false if @testInterval
                            @testInterval = setInterval(window.retest, 100)
                            return false
                        clean: =>
                            clearInterval(@testInterval)
                            @testInterval = null
                    
                    }
                ]
            }
        ]
    }
    {
        name: 'Building A Calculator'
        levels: [
            {
                id: 1362439206758
                challenge: '''
                    Figure out how to make the calculator perform the calculation 1 - 2.
                '''
                editors: [
                    {
                        title: 'Calculator Javascript'
                        type: 'javascript'
                        code: '''
                            function getScreen() {
                              return document.getElementById('screen'); 
                            }
                            function addToScreen(symbol) {
                              getScreen().innerHTML += symbol;
                            }

                            function subtract() {

                            }
                            var subtractButton = document.getElementById('subtract_button');
                            subtractButton.onclick = subtract;
                            
                            function add() {
                              addToScreen('+');
                            }
                            var addButton = document.getElementById('add_button');
                            addButton.onclick = add;

                            document.getElementById('number1').onclick = function() {
                              addToScreen(1);
                            };
                            document.getElementById('number2').onclick = function() {
                              addToScreen(2);
                            };          
                            
                            function calculate() {
                              equation = getScreen().innerHTML;
                              getScreen().innerHTML = eval(equation);
                            }
                            document.getElementById('equals').onclick = function() {
                              calculate();
                            };          

                            function clear() {
                              getScreen().innerHTML = '';
                            }
                            document.getElementById('clear').onclick = function() {
                              clear();
                            };          
                                   
                        '''
                    }
                    {
                        title: 'Calculator CSS'
                        type: 'css'
                        code: '''
                            .explanation {
                                float: right;
                                background-color: white;
                                border: 1px solid #ccc;
                                width: 36%;
                                margin-right: 12px;
                                padding: 12px;
                            }
                            
                            .calculator {
                                height: 360px;
                                width: 300px;
                                border: 1px solid #ccc;
                                background-color: white;
                                margin: 0 12px;
                            }
                            
                            .screen {
                                margin: 12px;
                                background-color: black;
                                height: 45px;
                                line-height: 45px;
                                color: white;
                                font-size: 42px;
                                text-align: right;                            
                            }
                            
                            .buttons .button {
                                float: left;
                                width: 36px;
                                height: 36px;
                                line-height: 36px;
                                text-align: center;
                                margin: 12px 0 0 12px;
                                background-color: #ccc;
                                color: black;
                                cursor: pointer;
                            }
                            
                            .buttons .numbers {
                                float: left;
                                border-right: 1px solid #ccc;
                                width: 58%;
                                height: 65%;
                            }
                            
                            .buttons .clear {
                                clear: both;
                                float: right;
                                margin-right: 12px;
                            }
                            
                            .buttons .equals, .buttons .clear {
                                width: 60px;
                            }
                        '''
                    }
                    {
                        title: 'Calculator HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <div class='explanation'>
                                  <b>A Working Calculator</b>
                                  <p>We're going to build a working calculator.</p>
                                  <p>All of the buttons are functional except for the subtraction button.</p>
                                  <p>You've got to figure out how to make it work.</p>
                                </div>
                              
                                <div class='calculator'>
                                  <div class='screen' id='screen'></div>
                                  <div class='buttons'>
                                    <div class='numbers'>
                                      <div class='number button' id='number1'>1</div>
                                      <div class='number button' id='number2'>2</div>
                                    </div>
                                    <div class='functions'>
                                      <div class='function button' id='add_button'>+</div>
                                      <div class='function button' id='subtract_button'>-</div>
                                    </div>
                                    <div class='clear button' id='clear'>Clear</div>
                                    <div class='equals button' id='equals'>=</div>
                                  </div>
                                </div>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                      Here we are working with some of the basics of javascript.
                    </p>
                    <p>
                      Some of the interesting javascript functions you might want to google
                      are 'javascript eval', 'javascript getElementById', and
                      'javascript innerHTML'.
                    </p>
                    <p>
                      Most importantly we are trying to figure out how to bind a method to
                      the onclick event of an html element. You may want to google 'javascript onclick'
                      for some more information about that.
                    </p>
                '''
                hints: [
                    'The subtraction button is going to work roughly the same as the addition button.'
                    'You can literally copy and paste the code in the add function.'
                    'Just change the symbol being sent to the screen to a \'-\' from a \'+\'.'
                    'Write this code in to the \'subtract\' function: \'addToScreen(\'-\')\''
                ]
                tests: [
                    {
                        description: 'When the equals sign is hit with \'1-2\' showing, the result is -1.'
                        test: ({body, cleanHtml}) =>
                            if not @equation and cleanHtml(body.find('#screen').html()) == '1-2'
                                @equation = true
                                return false
                            
                            if @equation and cleanHtml(body.find('#screen').html()) == '-1'
                                clearInterval(@testInterval)
                                return true 

                            return false if @testInterval
                            @testInterval = setInterval(window.retest, 100)
                            return false
                        clean: =>
                            @equation = null
                            clearInterval(@testInterval)
                            @testInterval = null                            
                    }
                ]
            }
            {
                id: 1362514980364
                challenge: '''
                    Figure out how to bind the multiplication button to the multiply function and perform the calculation 3*4.
                '''
                editors: [
                    {
                        title: 'Calculator Javascript'
                        type: 'javascript'
                        code: '''
                            function getScreen() {
                              return document.getElementById('screen'); 
                            }
                            function addToScreen(symbol) {
                              getScreen().innerHTML += symbol;
                            }

                            function multiply() {
                              addToScreen('*');
                            }


                            function subtract() {
                              addToScreen('-');
                            }
                            var subtractButton = document.getElementById('subtract_button');
                            subtractButton.onclick = subtract;
                            
                            function add() {
                              addToScreen('+');
                            }
                            var addButton = document.getElementById('add_button');
                            addButton.onclick = add;

                            function initializeNumberButton(number) {
                              document.getElementById('number' + number).onclick = function() {
                                addToScreen(number);
                              };                                
                            }
                            for (var i=1; i<=4; ++i) {
                              initializeNumberButton(i);
                            }
                            
                            function calculate() {
                              equation = getScreen().innerHTML;
                              getScreen().innerHTML = eval(equation);
                            }
                            document.getElementById('equals').onclick = function() {
                              calculate();
                            };          

                            function clear() {
                              getScreen().innerHTML = '';
                            }
                            document.getElementById('clear').onclick = function() {
                              clear();
                            };          
                                   
                        '''
                    }
                    {
                        title: 'Calculator CSS'
                        type: 'css'
                        code: '''
                            .explanation {
                                float: right;
                                background-color: white;
                                border: 1px solid #ccc;
                                width: 36%;
                                margin-right: 12px;
                                padding: 12px;
                            }
                            
                            .calculator {
                                height: 360px;
                                width: 300px;
                                border: 1px solid #ccc;
                                background-color: white;
                                margin: 0 12px;
                            }
                            
                            .screen {
                                margin: 12px;
                                background-color: black;
                                height: 45px;
                                line-height: 45px;
                                color: white;
                                font-size: 42px;
                                text-align: right;                            
                            }
                            
                            .buttons .button {
                                float: left;
                                width: 36px;
                                height: 36px;
                                line-height: 36px;
                                text-align: center;
                                margin: 12px 0 0 12px;
                                background-color: #ccc;
                                color: black;
                                cursor: pointer;
                            }
                            
                            .buttons .numbers {
                                float: left;
                                border-right: 1px solid #ccc;
                                width: 58%;
                                height: 65%;
                            }
                            
                            .buttons .clear {
                                clear: both;
                                float: right;
                                margin-right: 12px;
                            }
                            
                            .buttons .equals, .buttons .clear {
                                width: 60px;
                            }
                        '''
                    }
                    {
                        title: 'Calculator HTML'
                        type: 'html'
                        code: '''
                            <html>
                              <body>
                                <div class='explanation'>
                                  <b>A Working Calculator</b>
                                  <p>Now all of the buttons are functional except for the multiplication button.</p>
                                  <p>You've got to figure out how to make it work.</p>
                                </div>
                              
                                <div class='calculator'>
                                  <div class='screen' id='screen'></div>
                                  <div class='buttons'>
                                    <div class='numbers'>
                                      <div class='number button' id='number1'>1</div>
                                      <div class='number button' id='number2'>2</div>
                                      <div class='number button' id='number3'>3</div>
                                      <div class='number button' id='number4'>4</div>
                                    </div>
                                    <div class='functions'>
                                      <div class='function button' id='add_button'>+</div>
                                      <div class='function button' id='subtract_button'>-</div>
                                      <div class='function button' id='multiply_button'>*</div>
                                    </div>
                                    <div class='clear button' id='clear'>Clear</div>
                                    <div class='equals button' id='equals'>=</div>
                                  </div>
                                </div>
                              </body>
                            </html>
                        '''
                    }
                ]
                description: '''
                    <p>
                      Here we are working with some of the basics of javascript.
                    </p>
                    <p>
                      Some of the interesting javascript functions you might want to google
                      are 'javascript eval', 'javascript getElementById', and
                      'javascript innerHTML'.
                    </p>
                    <p>
                      Most importantly we are trying to figure out how to bind a method to
                      the onclick event of an html element. You may want to google 'javascript onclick'
                      for some more information about that.
                    </p>
                '''
                hints: [
                    'The multiplication button is going to work roughly the same as the subtraction button.'
                    'You can literally copy and paste the code for the subtraction button.'
                    'Just change the symbol being sent to the screen to a \'*\' from a \'-\', but don\'t forget to include the code the binds the function to the html element.'
                    '''
                    This is one example of code that would work:<br/><br/>
                    <span class='code'>
                    function multiply() {<br/>
                    &nbsp;&nbsp;addToScreen('*')<br/>
                    }<br/>
                    var multiplyButton = document.getElementById('multiply_button');<br/>
                    multiplyButton.onclick = multiply;
                    </span>
                    '''
                ]
                tests: [
                    {
                        description: 'When the equals sign is hit with \'3*4\' showing, the result is 12.'
                        test: ({body, cleanHtml}) =>
                            if not @equation and cleanHtml(body.find('#screen').html()) == '3*4'
                                @equation = true
                                return false
                            
                            if @equation and cleanHtml(body.find('#screen').html()) == '12'
                                clearInterval(@testInterval)
                                return true 

                            return false if @testInterval
                            @testInterval = setInterval(window.retest, 100)
                            return false
                        clean: =>
                            @equation = null
                            clearInterval(@testInterval)
                            @testInterval = null                            
                    }
                ]
            }
        ]
    }
    
]
