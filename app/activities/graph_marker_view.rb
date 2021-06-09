class GraphMarkerView < Com::Github::Mikephil::Charting::Components::MarkerView
    attr_accessor  :tvContent, :mOffset, :mOffset2, :mWeakChart

    def initialize (context, layoutResource) 
        super()
        mOffset = new_point
        mOffset2 = new_point

        setupLayoutResource(layoutResource)
    end

    def refreshContent(entry,  highlight)
        measure(measure_spec,
                measure_spec)
        layout(0, 0, getMeasuredWidth(), getMeasuredHeight())
    end

    def setupLayoutResource(layoutResource) 

        inflated = layout_inflater.from(getContext()).inflate(layoutResource, self)
        inflated.setLayoutParams(relative_layout_new)
        inflated.measure(measure_spec, measure_spec)
        inflated.layout(0, 0, inflated.getMeasuredWidth(), inflated.getMeasuredHeight())
    end

    def setOffset(offset) 
        mOffset = offset
        mOffset = new_point if (mOffset == null)
    end

    def setOffset(offsetX, offsetY) 
        mOffset.x = offsetX
        mOffset.y = offsetY
    end

    def getChartView() 
        mWeakChart == null ? null : mWeakChart.get()
    end

    def getOffsetForDrawingAtPoint(posX, posY) 

        offset = getOffset()
        mOffset2.x = offset.x
        mOffset2.y = offset.y

        chart = getChartView()

        width = getWidth()
         height = getHeight()

        if (posX + mOffset2.x < 0) 
            mOffset2.x = - posX
        elsif (chart != null && posX + width + mOffset2.x > chart.getWidth()) 
            mOffset2.x = chart.getWidth() - posX - width
        end

        if (posY + mOffset2.y < 0) 
            mOffset2.y = - posY
         elsif (chart != null && posY + height + mOffset2.y > chart.getHeight()) 
            mOffset2.y = chart.getHeight() - posY - height
        
        end

        mOffset2
    end

    def draw(canvas, posX, posY) 

        offset = getOffsetForDrawingAtPoint(posX, posY)

        saveId = canvas.save()
        canvas.translate(posX + offset.x, posY + offset.y)
        draw(canvas)
        canvas.restoreToCount(saveId)
    end

    def layout_inflater
        Android::View::LayoutInflater
    end    

    def measure_spec
        Android::View::View::MeasureSpec.makeMeasureSpec(0, unspecified)
    end    

    def new_point
        Com::Github::Mikephil::Charting::Utils::MPPointF.new()
    end 
    def wrap_content
        Android::Widget::RelativeLayout::LayoutParams::WRAP_CONTENT
    end

    def relative_layout_new
        Android::Widget::RelativeLayout::LayoutParams.new(wrap_content, wrap_content)
    end     

    def unspecified
        Android::View::View::MeasureSpec::UNSPECIFIED
    end

    def getOffset
        mOffset = MPPointF.new(-(getWidth() / 2), -getHeight()) if mOffset.nil?
        mOffset
    end

end
