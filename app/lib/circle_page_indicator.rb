class CirclePageIndicator < Android::View::View
  
  def onAttachedToWindow 
    return if isInEditMode
    res = getResources()
    @defaultPageColor = res.getColor(R::Color::Default_circle_indicator_page_color)
    @defaultFillColor = res.getColor(R::Color::Default_circle_indicator_fill_color)
    @defaultOrientation = res.getInteger(R::Integer::Default_circle_indicator_orientation)
    @defaultStrokeColor = res.getColor(R::Color::Default_circle_indicator_stroke_color)
    @defaultStrokeWidth = res.getDimension(R::Dimen::Default_circle_indicator_stroke_width)
    @defaultRadius = res.getDimension(R::Dimen::Default_circle_indicator_radius)
    @defaultCentered = res.getBoolean(R::Bool::Default_circle_indicator_centered)
    @defaultSnap = res.getBoolean(R::Bool::Default_circle_indicator_snap)
    
    @mPaintPageFill = Android::Graphics::Paint.new(Android::Graphics::Paint::ANTI_ALIAS_FLAG)
    @mPaintStroke = Android::Graphics::Paint.new(Android::Graphics::Paint::ANTI_ALIAS_FLAG)
    @mPaintFill = Android::Graphics::Paint.new(Android::Graphics::Paint::ANTI_ALIAS_FLAG)
    
    #a = getContext.obtainStyledAttributes(R::Styleable::CirclePageIndicator, 0)
    @mCentered = true
    @mOrientation = Android::Widget::LinearLayout::HORIZONTAL
    @mPaintPageFill.setStyle(Android::Graphics::Paint::Style::FILL)
    @mPaintPageFill.setColor(Android::Graphics::Color::WHITE)
    @mPaintPageFill.setAlpha(10);
    @mPaintStroke.setStyle(Android::Graphics::Paint::Style::STROKE)
    @mPaintStroke.setColor(Android::Graphics::Color::WHITE)
    @mPaintStroke.setStrokeWidth(3.5)
    @mPaintFill.setStyle(Android::Graphics::Paint::Style::FILL)
    @mPaintFill.setColor(Android::Graphics::Color::WHITE)
    @mRadius = 15.0
    @mSnap = true
    
    #background = a.getDrawable(R::Styleable::CirclePageIndicator_android_background)
    #setBackgroundDrawable(background) if background != null
    #a.recycle
    
    configuration = Android::View::ViewConfiguration.get(getContext);
    mTouchSlop = Android::Support::V4::View::ViewConfigurationCompat.getScaledPagingTouchSlop(configuration)
  end

  def onDraw(canvas) 
    super
    return if @mViewPager.nil?
    count = @mViewPager.getAdapter().getCount()
    return if count == 0
    if (@mCurrentPage >= count) 
      setCurrentItem(count - 1);
      return;
    end
    if (@mOrientation == Android::Widget::LinearLayout::HORIZONTAL) 
      longSize = getWidth();
      longPaddingBefore = getPaddingLeft();
      longPaddingAfter = getPaddingRight();
      shortPaddingBefore = getPaddingTop();
    else 
      longSize = getHeight();
      longPaddingBefore = getPaddingTop();
      longPaddingAfter = getPaddingBottom();
      shortPaddingBefore = getPaddingLeft();
    end
    threeRadius = @mRadius * 3;
    shortOffset = shortPaddingBefore + @mRadius;
    longOffset = longPaddingBefore + @mRadius;
    longOffset += ((longSize - longPaddingBefore - longPaddingAfter) / 2.0) - ((count * threeRadius) / 2.0) if @mCentered
    pageFillRadius = @mRadius
    pageFillRadius -= @mPaintStroke.getStrokeWidth() / 2.0 if @mPaintStroke.getStrokeWidth() > 0
    count.times do |index|
      drawLong = longOffset + (index * threeRadius);
      if (@mOrientation == Android::Widget::LinearLayout::HORIZONTAL) 
        dX = drawLong
        dY = shortOffset
      else 
        dX = shortOffset
        dY = drawLong
      end
      canvas.drawCircle(dX, dY, pageFillRadius, @mPaintPageFill) if @mPaintPageFill.getAlpha() > 0
      canvas.drawCircle(dX, dY, @mRadius, @mPaintStroke) if pageFillRadius != @mRadius
    end
    cx = @mCurrentPage * threeRadius
    cx += @mPageOffset * threeRadius unless @mSnap
    if (@mOrientation == Android::Widget::LinearLayout::HORIZONTAL)
      dX = longOffset + cx;
      dY = shortOffset;
    else 
      dX = shortOffset;
      dY = longOffset + cx;
    end
    canvas.drawCircle(dX, dY, @mRadius, @mPaintFill);
  end
  
  def setViewPager(view) 
    return if @mViewPager == view
    @mViewPager.addOnPageChangeListener(nil) unless @mViewPager.nil?
    @mViewPager = view;
    @mViewPager.addOnPageChangeListener(SimpleOnPageChangeListener.new(self))
    @mCurrentPage = 1;
    invalidate();
  end
  
  def setCurrentItem(item) 
    @mViewPager.setCurrentItem(item);
    @mCurrentPage = item;
    invalidate();
  end
  
  def notifyDataSetChanged
    invalidate
  end
  
  def onPageScrollStateChanged(state) 
    @mScrollState = state
  end

  def onPageScrolled(position, positionOffset, positionOffsetPixels)
    @mCurrentPage = position
    @mPageOffset = positionOffset
    invalidate()
  end

  def onPageSelected(position) 
    if (@mSnap || @mScrollState == Android::Support::V4::View::ViewPager::SCROLL_STATE_IDLE) 
      @mCurrentPage = position
      @mSnapPage = position
      invalidate();
    end
  end
  
  
  def onMeasure(widthMeasureSpec, heightMeasureSpec)
    setMeasuredDimension(measureLong(widthMeasureSpec), measureShort(heightMeasureSpec)) if @mOrientation == Android::Widget::LinearLayout::HORIZONTAL
    setMeasuredDimension(measureShort(widthMeasureSpec), measureLong(heightMeasureSpec)) unless @mOrientation == Android::Widget::LinearLayout::HORIZONTAL
  end
  
  def measureLong(measureSpec)
    specMode = Android::View::View::MeasureSpec.getMode(measureSpec)
    specSize = Android::View::View::MeasureSpec.getSize(measureSpec)
    if ((specMode == Android::View::View::MeasureSpec::EXACTLY) || @mViewPager.nil?)
      result = specSize
    else
      count = @mViewPager.getAdapter().getCount()
      result = getPaddingLeft + getPaddingRight + (count * 2 * @mRadius) + (count - 1) * @mRadius + 1
      result = [result, specSize].min   if specMode == Android::View::View::MeasureSpec::AT_MOST
    end
    result
  end
  
  def measureShort(measureSpec) 
    specMode = Android::View::View::MeasureSpec.getMode(measureSpec);
    specSize = Android::View::View::MeasureSpec.getSize(measureSpec);
    if specMode == Android::View::View::MeasureSpec::EXACTLY
      result = specSize
    else 
      result = (2 * @mRadius + getPaddingTop() + getPaddingBottom() + 1)
      result = [result, specSize].min if specMode == Android::View::View::MeasureSpec::AT_MOST
    end
    return result;
  end


end