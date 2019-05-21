function score = SSEQ( imdist )

    feature=feature_extract(imdist,3);
    score=SSQA_by_f(feature);
    
end

