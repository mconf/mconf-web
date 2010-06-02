/*
**
**	GalleryView - jQuery Content Gallery Plugin
**	Author: 		Jack Anderson
**	Version:		2.1 (March 14, 2010)
**	
**	Please use this development script if you intend to make changes to the
**	plugin code.  For production sites, please use jquery.galleryview-2.1-pack.js.
**	
**  See README.txt for instructions on how to markup your HTML
**
**	See CHANGELOG.txt for a review of changes and LICENSE.txt for the applicable
**	licensing information.
**
*/

//Global variable to check if window is already loaded
//Used for calling GalleryView after page has loaded
var window_loaded = false;
			
(function($){
	$.fn.galleryView = function(options) {
		var opts = $.extend($.fn.galleryView.defaults,options);
		
		var id;
		var iterator = 0;		// INT - Currently visible panel/frame
		var item_count = 0;		// INT - Total number of panels/frames
		var slide_method;		// STRING - indicator to slide entire filmstrip or just the pointer ('strip','pointer')
		var theme_path;			// STRING - relative path to theme directory
		var paused = false;		// BOOLEAN - flag to indicate whether automated transitions are active
		
	// Element dimensions
		var gallery_width;
		var gallery_height;
		var pointer_height;
		var pointer_width;
		var strip_width;
		var strip_height;
		var wrapper_width;
		var f_frame_width;
		var f_frame_height;
		var frame_caption_size = 20;
		var gallery_padding;
		var filmstrip_margin;
		var filmstrip_orientation;
		
		
	// Arrays used to scale frames and panels
		var frame_img_scale = {};
		var panel_img_scale = {};
		var img_h = {};
		var img_w = {};
		
	// Flag indicating whether to scale panel images
		var scale_panel_images = true;
		
		var panel_nav_displayed = false;
		
	// Define jQuery objects for reuse
		var j_gallery;
		var j_filmstrip;
		var j_frames;
		var j_frame_img_wrappers;
		var j_panels;
		var j_pointer;
		
		
/*
**	Plugin Functions
*/

	/*
	**	showItem(int)
	**		Transition from current frame to frame i (1-based index)
	*/
		function showItem(i) {
			// Disable next/prev buttons until transition is complete
			// This prevents overlapping of animations
			$('.nav-next-overlay',j_gallery).unbind('click');
			$('.nav-prev-overlay',j_gallery).unbind('click');
			$('.nav-next',j_gallery).unbind('click');
			$('.nav-prev',j_gallery).unbind('click');
			j_frames.unbind('click');
			
			if(opts.show_filmstrip) {
				// Fade out all frames
				j_frames.removeClass('current').find('img').stop().animate({
					'opacity':opts.frame_opacity
				},opts.transition_speed);
				// Fade in target frame
				j_frames.eq(i).addClass('current').find('img').stop().animate({
					'opacity':1.0
				},opts.transition_speed);
			}
			
			//If necessary, fade out all panels while fading in target panel
			if(opts.show_panels && opts.fade_panels) {
				j_panels.fadeOut(opts.transition_speed).eq(i%item_count).fadeIn(opts.transition_speed,function(){
					//If no filmstrip exists, re-bind click events to navigation buttons
					if(!opts.show_filmstrip) {
						$('.nav-prev-overlay',j_gallery).click(showPrevItem);
						$('.nav-next-overlay',j_gallery).click(showNextItem);
						$('.nav-prev',j_gallery).click(showPrevItem);
						$('.nav-next',j_gallery).click(showNextItem);		
					}
				});
			}
			
			// If gallery has a filmstrip, handle animation of frames
			if(opts.show_filmstrip) {
				// Slide either pointer or filmstrip, depending on transition method
				if(slide_method=='strip') {
					// Stop filmstrip if it's currently in motion
					j_filmstrip.stop();
					var distance;
					var diststr;
					if(filmstrip_orientation=='horizontal') {
						// Determine distance between pointer (eventual destination) and target frame
						distance = getPos(j_frames[i]).left - (getPos(j_pointer[0]).left+(pointer_width/2)-(f_frame_width/2));
						diststr = (distance>=0?'-=':'+=')+Math.abs(distance)+'px';
						
						// Animate filmstrip and slide target frame under pointer
						j_filmstrip.animate({
							'left':diststr
						},opts.transition_speed,opts.easing,function(){
							var old_i = i;
							// After transition is complete, shift filmstrip so that a sufficient number of frames
							// remain on either side of the visible filmstrip
							if(i>item_count) {
								i = i%item_count;
								iterator = i;
								j_filmstrip.css('left','-'+((f_frame_width+opts.frame_gap)*i)+'px');
							} else if (i<=(item_count-strip_size)) {
								i = (i%item_count)+item_count;
								iterator = i;
								j_filmstrip.css('left','-'+((f_frame_width+opts.frame_gap)*i)+'px');
							}
							// If the target frame has changed due to filmstrip shifting,
							// make sure new target frame has 'current' class and correct size/opacity settings
							if(old_i != i) {
								j_frames.eq(old_i).removeClass('current').find('img').css({
									'opacity':opts.frame_opacity
								});
								j_frames.eq(i).addClass('current').find('img').css({
									'opacity':1.0
								});
							}
							// If panels are not set to fade in/out, simply hide all panels and show the target panel
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}
							
							// Once animation is complete, re-bind click events to navigation buttons
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					} else { // filmstrip_orientation == 'vertical'
						//Determine distance between pointer (eventual destination) and target frame
						distance = getPos(j_frames[i]).top - (getPos(j_pointer[0]).top+(pointer_height)-(f_frame_height/2));
						diststr = (distance>=0?'-=':'+=')+Math.abs(distance)+'px';
						
						// Animate filmstrip and slide target frame under pointer
						j_filmstrip.animate({
							'top':diststr
						},opts.transition_speed,opts.easing,function(){
							// After transition is complete, shift filmstrip so that a sufficient number of frames
							// remain on either side of the visible filmstrip
							var old_i = i;
							if(i>item_count) {
								i = i%item_count;
								iterator = i;
								j_filmstrip.css('top','-'+((f_frame_height+opts.frame_gap)*i)+'px');
							} else if (i<=(item_count-strip_size)) {
								i = (i%item_count)+item_count;
								iterator = i;
								j_filmstrip.css('top','-'+((f_frame_height+opts.frame_gap)*i)+'px');
							}
							//If the target frame has changed due to filmstrip shifting,
							//Make sure new target frame has 'current' class and correct size/opacity settings
							if(old_i != i) {
								j_frames.eq(old_i).removeClass('current').find('img').css({
									'opacity':opts.frame_opacity
								});
								j_frames.eq(i).addClass('current').find('img').css({
									'opacity':1.0
								});
							}
							// If panels are not set to fade in/out, simply hide all panels and show the target panel
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}
							
							// Once animation is complete, re-bind click events to navigation buttons
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					}
				} else if(slide_method=='pointer') {
					// Stop pointer if it's currently in motion
					j_pointer.stop();
					// Get screen position of target frame
					var pos = getPos(j_frames[i]);
					
					if(filmstrip_orientation=='horizontal') {
						// Slide the pointer over the target frame
						j_pointer.animate({
							'left':(pos.left+(f_frame_width/2)-(pointer_width/2)+'px')
						},opts.transition_speed,opts.easing,function(){	
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}	
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					} else {
						// Slide the pointer over the target frame
						j_pointer.animate({
							'top':(pos.top+(f_frame_height/2)-(pointer_height)+'px')
						},opts.transition_speed,opts.easing,function(){	
							if(!opts.fade_panels) {
								j_panels.hide().eq(i%item_count).show();
							}	
							$('.nav-prev-overlay',j_gallery).click(showPrevItem);
							$('.nav-next-overlay',j_gallery).click(showNextItem);
							$('.nav-prev',j_gallery).click(showPrevItem);
							$('.nav-next',j_gallery).click(showNextItem);
							enableFrameClicking();
						});
					}
				}
			
			}
		};
		
	/*
	**	extraWidth(jQuery element)
	**		Return the combined width of the border and padding to the elements left and right.
	**		If the border is non-numerical, assume zero (not ideal, will fix later)
	**		RETURNS - int
	*/
		function extraWidth(el) {
			if(!el) { return 0; }
			if(el.length==0) { return 0; }
			el = el.eq(0);
			var ew = 0;
			ew += getInt(el.css('paddingLeft'));
			ew += getInt(el.css('paddingRight'));
			ew += getInt(el.css('borderLeftWidth'));
			ew += getInt(el.css('borderRightWidth'));
			return ew;
		};
		
	/*
	**	extraHeight(jQuery element)
	**		Return the combined height of the border and padding above and below the element
	**		If the border is non-numerical, assume zero (not ideal, will fix later)
	**		RETURN - int
	*/
		function extraHeight(el) {
			if(!el) { return 0; }
			if(el.length==0) { return 0; }
			el = el.eq(0);
			var eh = 0;
			eh += getInt(el.css('paddingTop'));
			eh += getInt(el.css('paddingBottom'));
			eh += getInt(el.css('borderTopWidth'));
			eh += getInt(el.css('borderBottomWidth'));
			return eh;
		};
	
	/*
	**	showNextItem()
	**		Transition from current frame to next frame
	*/
		function showNextItem() {
			
			// Cancel any transition timers until we have completed this function
			$(document).stopTime("transition");
			if(++iterator==j_frames.length) {iterator=0;}
			// We've already written the code to transition to an arbitrary panel/frame, so use it
			showItem(iterator);
			// If automated transitions haven't been cancelled by an option or paused on hover, re-enable them
			if(!paused) {
				$(document).everyTime(opts.transition_interval,"transition",function(){
					showNextItem();
				});
			}
		};
		
	/*
	**	showPrevItem()
	**		Transition from current frame to previous frame
	*/
		function showPrevItem() {
			// Cancel any transition timers until we have completed this function
			$(document).stopTime("transition");
			if(--iterator<0) {iterator = item_count-1;}
			// We've already written the code to transition to an arbitrary panel/frame, so use it
			showItem(iterator);
			// If automated transitions haven't been cancelled by an option or paused on hover, re-enable them
			if(!paused) {
				$(document).everyTime(opts.transition_interval,"transition",function(){
					showNextItem();
				});
			}
		};
		
	/*
	**	getPos(jQuery element
	**		Calculate position of an element relative to top/left corner of gallery
	**		If the gallery bounding box itself is passed to the function, calculate position of gallery relative to top/left corner of browser window
	** 		RETURNS - JSON {left: int, top: int}
	*/
		function getPos(el) {
			var left = 0, top = 0;
			var el_id = el.id;
			if(el.offsetParent) {
				do {
					left += el.offsetLeft;
					top += el.offsetTop;
				} while(el = el.offsetParent);
			}
			//If we want the position of the gallery itself, return it
			if(el_id == id) {return {'left':left,'top':top};}
			//Otherwise, get position of element relative to gallery
			else {
				var gPos = getPos(j_gallery[0]);
				var gLeft = gPos.left;
				var gTop = gPos.top;
				
				return {'left':left-gLeft,'top':top-gTop};
			}
		};
	
	/*
	**	enableFrameClicking()
	**		Add an onclick event handler to each frame
	**		Exception: if a frame has an anchor tag, do not add an onlick handler
	*/
		function enableFrameClicking() {
			j_frames.each(function(i){
				if($('a',this).length==0) {
					$(this).click(function(){
						// Prevent transitioning to the current frame (unnecessary)
						if(iterator!=i) {
							$(document).stopTime("transition");
							showItem(i);
							iterator = i;
							if(!paused) {
								$(document).everyTime(opts.transition_interval,"transition",function(){
									showNextItem();
								});
							}
						}
					});
				}
			});
		};
	
	/*
	**	buildPanels()
	**		Construct gallery panels from <div class="panel"> elements
	**		NOTE - These DIVs are generated automatically from the content of the UL passed to the plugin
	*/
		function buildPanels() {
			// If panel overlay content exists, add the necessary overlay background DIV
			// The overlay content and background are separate elements so the background's opacity isn't inherited by the content
			j_panels.each(function(i){
		   		if($('.panel-overlay',this).length>0) {
					$(this).append('<div class="overlay-background"></div>');	
				}
		   	});
			// If there is no filmstrip in this gallery, add navigation buttons to the panel itself
			if(!opts.show_filmstrip) {
				$('<img />').addClass('nav-next').attr('src',theme_path+opts.nav_theme+'/next.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1100',
					'cursor':'pointer',
					'top':((opts.panel_height-22)/2)+gallery_padding+'px',
					'right':'10px',
					'display':'none'
				}).click(showNextItem);
				$('<img />').addClass('nav-prev').attr('src',theme_path+opts.nav_theme+'/prev.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1100',
					'cursor':'pointer',
					'top':((opts.panel_height-22)/2)+gallery_padding+'px',
					'left':'10px',
					'display':'none'
				}).click(showPrevItem);
				
				$('<img />').addClass('nav-next-overlay').attr('src',theme_path+opts.nav_theme+'/panel-nav-next.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1099',
					'top':((opts.panel_height-22)/2)+gallery_padding-10+'px',
					'right':'0',
					'display':'none',
					'cursor':'pointer',
					'opacity':0.75
				}).click(showNextItem);
				
				$('<img />').addClass('nav-prev-overlay').attr('src',theme_path+opts.nav_theme+'/panel-nav-prev.gif').appendTo(j_gallery).css({
					'position':'absolute',
					'zIndex':'1099',
					'top':((opts.panel_height-22)/2)+gallery_padding-10+'px',
					'left':'0',
					'display':'none',
					'cursor':'pointer',
					'opacity':0.75
				}).click(showPrevItem);
			}
			// Set the height and width of each panel, and position it appropriately within the gallery
			j_panels.each(function(i){
				$(this).css({
					'width':(opts.panel_width-extraWidth(j_panels))+'px',
					'height':(opts.panel_height-extraHeight(j_panels))+'px',
					'position':'absolute',
					'overflow':'hidden',
					'display':'none'
				});
				switch(opts.filmstrip_position) {
					case 'top': $(this).css({
									'top':strip_height+Math.max(gallery_padding,filmstrip_margin)+'px',
									'left':gallery_padding+'px'
								}); break;
					case 'left': $(this).css({
								 	'top':gallery_padding+'px',
									'left':strip_width+Math.max(gallery_padding,filmstrip_margin)+'px'
								 }); break;
					default: $(this).css({'top':gallery_padding+'px','left':gallery_padding+'px'}); break;
				}
			});
			// Position each panel overlay within panel
			$('.panel-overlay',j_panels).css({
				'position':'absolute',
				'zIndex':'999',
				'width':(opts.panel_width-extraWidth($('.panel-overlay',j_panels)))+'px',
				'left':'0'
			});
			$('.overlay-background',j_panels).css({
				'position':'absolute',
				'zIndex':'998',
				'width':opts.panel_width+'px',
				'left':'0',
				'opacity':opts.overlay_opacity
			});
			if(opts.overlay_position=='top') {
				$('.panel-overlay',j_panels).css('top',0);
				$('.overlay-background',j_panels).css('top',0);
			} else {
				$('.panel-overlay',j_panels).css('bottom',0);
				$('.overlay-background',j_panels).css('bottom',0);
			}
			
			$('.panel iframe',j_panels).css({
				'width':opts.panel_width+'px',
				'height':opts.panel_height+'px',
				'border':'0'
			});
			
			// If panel images have to be scaled to fit within frame, do so and position them accordingly
			if(scale_panel_images) {
				$('img',j_panels).each(function(i){
					$(this).css({
						'height':panel_img_scale[i%item_count]*img_h[i%item_count],
						'width':panel_img_scale[i%item_count]*img_w[i%item_count],
						'position':'relative',
						'top':(opts.panel_height-(panel_img_scale[i%item_count]*img_h[i%item_count]))/2+'px',
						'left':(opts.panel_width-(panel_img_scale[i%item_count]*img_w[i%item_count]))/2+'px'
					});
				});
			}
		};
	
	/*
	**	buildFilmstrip()
	**		Construct filmstrip from <ul class="filmstrip"> element
	**		NOTE - 'filmstrip' class is automatically added to UL passed to plugin
	*/
		function buildFilmstrip() {
			// Add wrapper to filmstrip to hide extra frames
			j_filmstrip.wrap('<div class="strip_wrapper"></div>');
			if(slide_method=='strip') {
				j_frames.clone().appendTo(j_filmstrip);
				j_frames.clone().appendTo(j_filmstrip);
				j_frames = $('li',j_filmstrip);
			}
			// If captions are enabled, add caption DIV to each frame and fill with the image titles
			if(opts.show_captions) {
				j_frames.append('<div class="caption"></div>').each(function(i){
					$(this).find('.caption').html($(this).find('img').attr('title'));	
					//$(this).find('.caption').html(i);		
				});
			}
			// Position the filmstrip within the gallery
			j_filmstrip.css({
				'listStyle':'none',
				'margin':'0',
				'padding':'0',
				'width':strip_width+'px',
				'position':'absolute',
				'zIndex':'900',
				'top':(filmstrip_orientation=='vertical' && slide_method=='strip'?-((f_frame_height+opts.frame_gap)*iterator):0)+'px',
				'left':(filmstrip_orientation=='horizontal' && slide_method=='strip'?-((f_frame_width+opts.frame_gap)*iterator):0)+'px',
				'height':strip_height+'px'
			});
			j_frames.css({
				'float':'left',
				'position':'relative',
				'height':f_frame_height+(opts.show_captions?frame_caption_size:0)+'px',
				'width':f_frame_width+'px',
				'zIndex':'901',
				'padding':'0',
				'cursor':'pointer'
			});
			// Set frame margins based on user options and position of filmstrip within gallery
			switch(opts.filmstrip_position) {
				case 'top': j_frames.css({
								'marginBottom':filmstrip_margin+'px',
								'marginRight':opts.frame_gap+'px'
							}); break;
				case 'bottom': j_frames.css({
								'marginTop':filmstrip_margin+'px',
								'marginRight':opts.frame_gap+'px'
							}); break;
				case 'left': j_frames.css({
								'marginRight':filmstrip_margin+'px',
								'marginBottom':opts.frame_gap+'px'
							}); break;
				case 'right': j_frames.css({
								'marginLeft':filmstrip_margin+'px',
								'marginBottom':opts.frame_gap+'px'
							}); break;
			}
			// Apply styling to individual image wrappers. These will eventually hide overflow in the case of cropped filmstrip images
			$('.img_wrap',j_frames).each(function(i){								  
				$(this).css({
					'height':Math.min(opts.frame_height,img_h[i%item_count]*frame_img_scale[i%item_count])+'px',
					'width':Math.min(opts.frame_width,img_w[i%item_count]*frame_img_scale[i%item_count])+'px',
					'position':'relative',
					'top':(opts.show_captions && opts.filmstrip_position=='top'?frame_caption_size:0)+Math.max(0,(opts.frame_height-(frame_img_scale[i%item_count]*img_h[i%item_count]))/2)+'px',
					'left':Math.max(0,(opts.frame_width-(frame_img_scale[i%item_count]*img_w[i%item_count]))/2)+'px',
					'overflow':'hidden'
				});
			});
			// Scale each filmstrip image if necessary and position it within the image wrapper
			$('img',j_frames).each(function(i){
				$(this).css({
					'opacity':opts.frame_opacity,
					'height':img_h[i%item_count]*frame_img_scale[i%item_count]+'px',
					'width':img_w[i%item_count]*frame_img_scale[i%item_count]+'px',
					'position':'relative',
					'top':Math.min(0,(opts.frame_height-(frame_img_scale[i%item_count]*img_h[i%item_count]))/2)+'px',
					'left':Math.min(0,(opts.frame_width-(frame_img_scale[i%item_count]*img_w[i%item_count]))/2)+'px'
	
				}).mouseover(function(){
					$(this).stop().animate({'opacity':1.0},300);
				}).mouseout(function(){
					//Don't fade out current frame on mouseout
					if(!$(this).parent().parent().hasClass('current')) { $(this).stop().animate({'opacity':opts.frame_opacity},300); }
				});
			});
			// Set overflow of filmstrip wrapper to hidden so as to hide frames that don't fit within the gallery
			$('.strip_wrapper',j_gallery).css({
				'position':'absolute',
				'overflow':'hidden'
			});
			// Position filmstrip within gallery based on user options
			if(filmstrip_orientation=='horizontal') {
				$('.strip_wrapper',j_gallery).css({
					'top':(opts.filmstrip_position=='top'?Math.max(gallery_padding,filmstrip_margin)+'px':opts.panel_height+gallery_padding+'px'),
					'left':((gallery_width-wrapper_width)/2)+gallery_padding+'px',
					'width':wrapper_width+'px',
					'height':strip_height+'px'
				});
			} else {
				$('.strip_wrapper',j_gallery).css({
					'left':(opts.filmstrip_position=='left'?Math.max(gallery_padding,filmstrip_margin)+'px':opts.panel_width+gallery_padding+'px'),
					'top':Math.max(gallery_padding,opts.frame_gap)+'px',
					'width':strip_width+'px',
					'height':wrapper_height+'px'
				});
			}
			// Style frame captions
			$('.caption',j_gallery).css({
				'position':'absolute',
				'top':(opts.filmstrip_position=='bottom'?f_frame_height:0)+'px',
				'left':'0',
				'margin':'0',
				'width':f_frame_width+'px',
				'padding':'0',
				'height':frame_caption_size+'px',
				'overflow':'hidden',
				'lineHeight':frame_caption_size+'px'
			});
			// Create pointer for current frame
			var pointer = $('<div></div>');
			pointer.addClass('pointer').appendTo(j_gallery).css({
				 'position':'absolute',
				 'zIndex':'1000',
				 'width':'0px',
				 'fontSize':'0px',
				 'lineHeight':'0%',
				 'borderTopWidth':pointer_height+'px',
				 'borderRightWidth':(pointer_width/2)+'px',
				 'borderBottomWidth':pointer_height+'px',
				 'borderLeftWidth':(pointer_width/2)+'px',
				 'borderStyle':'solid'
			});
			
			// For IE6, use predefined color string in place of transparent (IE6 bug fix, see stylesheet)
			var transColor = $.browser.msie && $.browser.version.substr(0,1)=='6' ? 'pink' : 'transparent';
			
			// If there are no panels, make pointer transparent (nothing to point to)
			// This is not the optimal solution, but we need the pointer to exist as a reference for transition animations
			if(!opts.show_panels) { pointer.css('borderColor',transColor); }
		
				switch(opts.filmstrip_position) {
					case 'top': pointer.css({
									'bottom':(opts.panel_height-(pointer_height*2)+gallery_padding+filmstrip_margin)+'px',
				 					'left':((gallery_width-wrapper_width)/2)+(slide_method=='strip'?0:((f_frame_width+opts.frame_gap)*iterator))+((f_frame_width/2)-(pointer_width/2))+gallery_padding+'px',
									'borderBottomColor':transColor,
									'borderRightColor':transColor,
									'borderLeftColor':transColor
								}); break;
					case 'bottom': pointer.css({
										'top':(opts.panel_height-(pointer_height*2)+gallery_padding+filmstrip_margin)+'px',
				 						'left':((gallery_width-wrapper_width)/2)+(slide_method=='strip'?0:((f_frame_width+opts.frame_gap)*iterator))+((f_frame_width/2)-(pointer_width/2))+gallery_padding+'px',
										'borderTopColor':transColor,
										'borderRightColor':transColor,
										'borderLeftColor':transColor
									}); break;
					case 'left': pointer.css({
									'right':(opts.panel_width-pointer_width+gallery_padding+filmstrip_margin)+'px',
				 					'top':(f_frame_height/2)-(pointer_height)+(slide_method=='strip'?0:((f_frame_height+opts.frame_gap)*iterator))+gallery_padding+'px',
									'borderBottomColor':transColor,
									'borderRightColor':transColor,
									'borderTopColor':transColor
								}); break;
					case 'right': pointer.css({
									'left':(opts.panel_width-pointer_width+gallery_padding+filmstrip_margin)+'px',
				 					'top':(f_frame_height/2)-(pointer_height)+(slide_method=='strip'?0:((f_frame_height+opts.frame_gap)*iterator))+gallery_padding+'px',
									'borderBottomColor':transColor,
									'borderLeftColor':transColor,
									'borderTopColor':transColor
								}); break;
				}
		
			j_pointer = $('.pointer',j_gallery);
			
			// Add navigation buttons
			var navNext = $('<img />');
			navNext.addClass('nav-next').attr('src',theme_path+opts.nav_theme+'/next.gif').appendTo(j_gallery).css({
				'position':'absolute',
				'cursor':'pointer'
			}).click(showNextItem);
			var navPrev = $('<img />');
			navPrev.addClass('nav-prev').attr('src',theme_path+opts.nav_theme+'/prev.gif').appendTo(j_gallery).css({
				'position':'absolute',
				'cursor':'pointer'
			}).click(showPrevItem);
			if(filmstrip_orientation=='horizontal') {
				navNext.css({					 
					'top':(opts.filmstrip_position=='top'?Math.max(gallery_padding,filmstrip_margin):opts.panel_height+filmstrip_margin+gallery_padding)+((f_frame_height-22)/2)+'px',
					'right':((gallery_width+(gallery_padding*2))/2)-(wrapper_width/2)-opts.frame_gap-22+'px'
				});
				navPrev.css({
					'top':(opts.filmstrip_position=='top'?Math.max(gallery_padding,filmstrip_margin):opts.panel_height+filmstrip_margin+gallery_padding)+((f_frame_height-22)/2)+'px',
					'left':((gallery_width+(gallery_padding*2))/2)-(wrapper_width/2)-opts.frame_gap-22+'px'
				 });
			} else {
				navNext.css({					 
					'left':(opts.filmstrip_position=='left'?Math.max(gallery_padding,filmstrip_margin):opts.panel_width+filmstrip_margin+gallery_padding)+((f_frame_width-22)/2)+13+'px',
					'top':wrapper_height+(Math.max(gallery_padding,opts.frame_gap)*2)+'px'
				});
				navPrev.css({
					'left':(opts.filmstrip_position=='left'?Math.max(gallery_padding,filmstrip_margin):opts.panel_width+filmstrip_margin+gallery_padding)+((f_frame_width-22)/2)-13+'px',
					'top':wrapper_height+(Math.max(gallery_padding,opts.frame_gap)*2)+'px'
				});
			}
		};
	
	/*
	**	mouseIsOverGallery(int,int)
	**		Check to see if mouse coordinates lie within borders of gallery
	**		This is a more reliable method than using the mouseover event
	**		RETURN - boolean
	*/
		function mouseIsOverGallery(x,y) {		
			var pos = getPos(j_gallery[0]);
			var top = pos.top;
			var left = pos.left;
			return x > left && x < left+gallery_width+(filmstrip_orientation=='horizontal'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin)) && y > top && y < top+gallery_height+(filmstrip_orientation=='vertical'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin));				
		};
	
	/*
	**	getInt(string)
	**		Parse a string to obtain the integer value contained
	**		If the string contains no number, return zero
	**		RETURN - int
	*/
		function getInt(i) {
			i = parseInt(i,10);
			if(isNaN(i)) { i = 0; }
			return i;	
		};
	
	/*
	**	buildGallery()
	**		Construct HTML and CSS for the gallery, based on user options
	*/
		function buildGallery() {
			var gallery_images = opts.show_filmstrip?$('img',j_frames):$('img',j_panels);
			// For each image in the gallery, add its original dimensions and scaled dimensions to the appropriate arrays for later reference
			gallery_images.each(function(i){
				img_h[i] = this.height;
				img_w[i] = this.width;
				if(opts.frame_scale=='nocrop') {
					frame_img_scale[i] = Math.min(opts.frame_height/img_h[i],opts.frame_width/img_w[i]);
				} else {
					frame_img_scale[i] = Math.max(opts.frame_height/img_h[i],opts.frame_width/img_w[i]);
				}
				
				if(opts.panel_scale=='nocrop') {
					panel_img_scale[i] = Math.min(opts.panel_height/img_h[i],opts.panel_width/img_w[i]);
				} else {
					panel_img_scale[i] = Math.max(opts.panel_height/img_h[i],opts.panel_width/img_w[i]);
				}
			});
			
			// Size gallery based on position of filmstrip
			j_gallery.css({
				'position':'relative',
				'width':gallery_width+(filmstrip_orientation=='horizontal'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px',
				'height':gallery_height+(filmstrip_orientation=='vertical'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px'
			});
			
			// Build filmstrip if necessary
			if(opts.show_filmstrip) {
				buildFilmstrip();
				enableFrameClicking();
			}
			// Build panels if necessary
			if(opts.show_panels) {
				buildPanels();
			}
			
			// If user opts to pause on hover, or no filmstrip exists, add some mouseover functionality
			if(opts.pause_on_hover || (opts.show_panels && !opts.show_filmstrip)) {
				$(document).mousemove(function(e){
					if(mouseIsOverGallery(e.pageX,e.pageY)) {
						// If the user opts to pause on hover, kill automated transitions
						if(opts.pause_on_hover) {
							if(!paused) {
								// Pause slideshow in 500ms
								$(document).oneTime(500,"animation_pause",function(){
									$(document).stopTime("transition");
									paused=true;
								});
							}
						}
						// Display panel navigation on mouseover
						if(opts.show_panels && !opts.show_filmstrip && !panel_nav_displayed) {
							$('.nav-next-overlay').fadeIn('fast');
							$('.nav-prev-overlay').fadeIn('fast');
							$('.nav-next',j_gallery).fadeIn('fast');
							$('.nav-prev',j_gallery).fadeIn('fast');
							panel_nav_displayed = true;
						}
					} else {
						// If the mouse leaves the gallery, stop the pause timer and restart automated transitions
						if(opts.pause_on_hover) {
							$(document).stopTime("animation_pause");
							if(paused) {
								$(document).everyTime(opts.transition_interval,"transition",function(){
									showNextItem();
								});
								paused = false;
							}
						}
						// Hide panel navigation
						if(opts.show_panels && !opts.show_filmstrip && panel_nav_displayed) {
							$('.nav-next-overlay').fadeOut('fast');
							$('.nav-prev-overlay').fadeOut('fast');
							$('.nav-next',j_gallery).fadeOut('fast');
							$('.nav-prev',j_gallery).fadeOut('fast');
							panel_nav_displayed = false;
						}
					}
				});
			}
			
			// Hide loading box and display gallery
			j_filmstrip.css('visibility','visible');
			j_gallery.css('visibility','visible');
			$('.loader',j_gallery).fadeOut('1000',function(){
				// Show the 'first' panel (set by opts.start_frame)
				showItem(iterator);
				// If we have more than one item, begin automated transitions
				if(item_count > 1) {
					$(document).everyTime(opts.transition_interval,"transition",function(){
						showNextItem();
					});
				}	
			});	
		};
		
	/*
	**	MAIN PLUGIN CODE
	*/
		return this.each(function() {
			//Hide the unstyled UL until we've created the gallery
			$(this).css('visibility','hidden');
			
			// Wrap UL in DIV and transfer ID to container DIV
			$(this).wrap("<div></div>");
			j_gallery = $(this).parent();
			j_gallery.css('visibility','hidden').attr('id',$(this).attr('id')).addClass('gallery');
			
			// Assign filmstrip class to UL
			$(this).removeAttr('id').addClass('filmstrip');
			
			// If the transition or pause timers exist for any reason, stop them now.
			$(document).stopTime("transition");
			$(document).stopTime("animation_pause");
			
			// Save the id of the UL passed to the plugin
			id = j_gallery.attr('id');
			
			// If the UL does not contain any <div class="panel-content"> elements, we will scale the UL images to fill the panels
			scale_panel_images = $('.panel-content',j_gallery).length==0;
			
			// Define dimensions of pointer <div>
			pointer_height = opts.pointer_size;
			pointer_width = opts.pointer_size*2;
			
			// Determine filmstrip orientation (vertical or horizontal)
			// Do not show captions on vertical filmstrips (override user set option)
			filmstrip_orientation = (opts.filmstrip_position=='top'||opts.filmstrip_position=='bottom'?'horizontal':'vertical');
			if(filmstrip_orientation=='vertical') { opts.show_captions = false; }
			
			// Determine path between current page and plugin images
			// Scan script tags and look for path to GalleryView plugin
			$('script').each(function(i){
				var s = $(this);
				if(s.attr('src') && s.attr('src').match(/jquery\.galleryview/)){
					loader_path = s.attr('src').split('jquery.galleryview')[0];
					theme_path = s.attr('src').split('jquery.galleryview')[0]+'themes/';	
				}
			});
			
			// Assign elements to variables to minimize calls to jQuery
			j_filmstrip = $('.filmstrip',j_gallery);
			j_frames = $('li',j_filmstrip);
			j_frames.addClass('frame');
			
			// If the user wants panels, generate them using the filmstrip images
			if(opts.show_panels) {
				for(i=j_frames.length-1;i>=0;i--) {
					if(j_frames.eq(i).find('.panel-content').length>0) {
						j_frames.eq(i).find('.panel-content').remove().prependTo(j_gallery).addClass('panel');
					} else {
						p = $('<div>');
						p.addClass('panel');
						im = $('<img />');
						im.attr('src',j_frames.eq(i).find('img').eq(0).attr('src')).appendTo(p);
						p.prependTo(j_gallery);
						j_frames.eq(i).find('.panel-overlay').remove().appendTo(p);
					}
				}
			} else { 
				$('.panel-overlay',j_frames).remove(); 
				$('.panel-content',j_frames).remove();
			}
			
			// If the user doesn't want a filmstrip, delete it
			if(!opts.show_filmstrip) { j_filmstrip.remove(); }
			else {
				// Wrap the frame images (and links, if applicable) in container divs
				// These divs will handle cropping and zooming of the images
				j_frames.each(function(i){
					if($(this).find('a').length>0) {
						$(this).find('a').wrap('<div class="img_wrap"></div>');
					} else {
						$(this).find('img').wrap('<div class="img_wrap"></div>');	
					}
				});
				j_frame_img_wrappers = $('.img_wrap',j_frames);
			}
			
			j_panels = $('.panel',j_gallery);
			
			if(!opts.show_panels) {
				opts.panel_height = 0;
				opts.panel_width = 0;
			}
			
			
			// Determine final frame dimensions, accounting for user-added padding and border
			f_frame_width = opts.frame_width+extraWidth(j_frame_img_wrappers);
			f_frame_height = opts.frame_height+extraHeight(j_frame_img_wrappers);
			
			// Number of frames in filmstrip
			item_count = opts.show_panels?j_panels.length:j_frames.length;
			
			// Number of frames that can display within the gallery block
			// 64 = width of block for navigation button * 2 + 20
			if(filmstrip_orientation=='horizontal') {
				strip_size = opts.show_panels?Math.floor((opts.panel_width-((opts.frame_gap+22)*2))/(f_frame_width+opts.frame_gap)):Math.min(item_count,opts.filmstrip_size); 
			} else {
				strip_size = opts.show_panels?Math.floor((opts.panel_height-(opts.frame_gap+22))/(f_frame_height+opts.frame_gap)):Math.min(item_count,opts.filmstrip_size);
			}
			
			// Determine animation method for filmstrip
			// If more items than strip size, slide filmstrip
			// Otherwise, slide pointer
			if(strip_size >= item_count) {
				slide_method = 'pointer';
				strip_size = item_count;
			}
			else {slide_method = 'strip';}
			
			iterator = (strip_size<item_count?item_count:0)+opts.start_frame-1;
			
			// Determine dimensions of various gallery elements
			filmstrip_margin = (opts.show_panels?getInt(j_filmstrip.css('marginTop')):0);
			j_filmstrip.css('margin','0px');
			
			if(filmstrip_orientation=='horizontal') {
				// Width of gallery block
				gallery_width = opts.show_panels?opts.panel_width:(strip_size*(f_frame_width+opts.frame_gap))+44+opts.frame_gap;
				
				// Height of gallery block = screen + filmstrip + captions (optional)
				gallery_height = (opts.show_panels?opts.panel_height:0)+(opts.show_filmstrip?f_frame_height+filmstrip_margin+(opts.show_captions?frame_caption_size:0):0);
			} else {
				// Width of gallery block
				gallery_height = opts.show_panels?opts.panel_height:(strip_size*(f_frame_height+opts.frame_gap))+22;
				
				// Height of gallery block = screen + filmstrip + captions (optional)
				gallery_width = (opts.show_panels?opts.panel_width:0)+(opts.show_filmstrip?f_frame_width+filmstrip_margin:0);
			}
			
			// Width of filmstrip
			if(filmstrip_orientation=='horizontal') {
				if(slide_method == 'pointer') {strip_width = (f_frame_width*item_count)+(opts.frame_gap*(item_count));}
				else {strip_width = (f_frame_width*item_count*3)+(opts.frame_gap*(item_count*3));}
			} else {
				strip_width = (f_frame_width+filmstrip_margin);
			}
			if(filmstrip_orientation=='horizontal') {
				strip_height = (f_frame_height+filmstrip_margin+(opts.show_captions?frame_caption_size:0));	
			} else {
				if(slide_method == 'pointer') {strip_height = (f_frame_height*item_count+opts.frame_gap*(item_count));}
				else {strip_height = (f_frame_height*item_count*3)+(opts.frame_gap*(item_count*3));}
			}
			
			// Width of filmstrip wrapper (to hide overflow)
			wrapper_width = ((strip_size*f_frame_width)+((strip_size-1)*opts.frame_gap));
			wrapper_height = ((strip_size*f_frame_height)+((strip_size-1)*opts.frame_gap));

			
			gallery_padding = getInt(j_gallery.css('paddingTop'));
			j_gallery.css('padding','0px');

			// Place loading box over gallery until page loads
			galleryPos = getPos(j_gallery[0]);
			$('<div>').addClass('loader').css({
				'position':'absolute',
				'zIndex':'32666',
				'opacity':1,
				'top':'0px',
				'left':'0px',
				'width':gallery_width+(filmstrip_orientation=='horizontal'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px',
				'height':gallery_height+(filmstrip_orientation=='vertical'?(gallery_padding*2):gallery_padding+Math.max(gallery_padding,filmstrip_margin))+'px'
			}).appendTo(j_gallery);
					
			// Don't call the buildGallery function until the window is loaded
			// NOTE - lazy way of waiting until all images are loaded, may find a better solution for future versions
			if(!window_loaded) {
				$(window).load(function(){
					window_loaded = true;
					buildGallery();
				});
			} else {
				buildGallery();
			}
					
		});
	};
	
/*
**	GalleryView options and default values
*/
	$.fn.galleryView.defaults = {
		
		show_panels: true,					//BOOLEAN - flag to show or hide panel portion of gallery
		show_filmstrip: true,				//BOOLEAN - flag to show or hide filmstrip portion of gallery
		
		panel_width: 320,					//INT - width of gallery panel (in pixels)
		panel_height: 245,					//INT - height of gallery panel (in pixels)
		frame_width: 30,					//INT - width of filmstrip frames (in pixels)
		frame_height: 30,					//INT - width of filmstrip frames (in pixels)
		
		start_frame: 1,						//INT - index of panel/frame to show first when gallery loads
		filmstrip_size: 3,					
		transition_speed: 800,				//INT - duration of panel/frame transition (in milliseconds)
		transition_interval: 4000,			//INT - delay between panel/frame transitions (in milliseconds)
		
		overlay_opacity: 0.7,				//FLOAT - transparency for panel overlay (1.0 = opaque, 0.0 = transparent)
		frame_opacity: 0.3,					//FLOAT - transparency of non-active frames (1.0 = opaque, 0.0 = transparent)
		
		pointer_size: 7,					//INT - Height of frame pointer (in pixels)
		
		nav_theme: 'dark',					//STRING - name of navigation theme to use (folder must exist within 'themes' directory)
		easing: 'swing',					//STRING - easing method to use for animations (jQuery provides 'swing' or 'linear', more available with jQuery UI or Easing plugin)
		
		filmstrip_position: 'bottom',		//STRING - position of filmstrip within gallery (bottom, top, left, right)
		overlay_position: 'bottom',			//STRING - position of panel overlay (bottom, top, left, right)
		
		panel_scale: 'nocrop',				//STRING - cropping option for panel images (crop = scale image and fit to aspect ratio determined by panel_width and panel_height, nocrop = scale image and preserve original aspect ratio)
		frame_scale: 'crop',				//STRING - cropping option for filmstrip images (same as above)
		
		frame_gap: 10,						//INT - spacing between frames within filmstrip (in pixels)
		
		show_captions: false,				//BOOLEAN - flag to show or hide frame captions
		fade_panels: true,					//BOOLEAN - flag to fade panels during transitions or swap instantly
		pause_on_hover: false				//BOOLEAN - flag to pause slideshow when user hovers over the gallery
	};
})(jQuery);