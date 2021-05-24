package com.example.myweatherapp;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentStatePagerAdapter;
import androidx.viewpager.widget.PagerAdapter;
import androidx.viewpager.widget.ViewPager;
//import androidx.viewpager.widget.ViewPager;


import android.os.Bundle;
import androidx.appcompat.widget.Toolbar;

public class MainActivity extends AppCompatActivity {

    private static final int NUM_PAGES = 3;
    private PagerAdapter cardsAdapter;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
//       Toolbar myToolbar = (Toolbar) findViewById(R.id.toolbar);
//       setSupportActionBar(myToolbar);
        setContentView(R.layout.activity_main);
        ViewPager cards =  findViewById(R.id.pager);
        cardsAdapter = new ScreenSlidePagerAdapter(getSupportFragmentManager());
        cards.setAdapter(cardsAdapter);
        JsonEncoder.buildRequest("lodz",this);
    }



    private class ScreenSlidePagerAdapter extends FragmentStatePagerAdapter {
        public ScreenSlidePagerAdapter(FragmentManager fm) {
            super(fm);
        }

        @NonNull
        @Override
        public Fragment getItem(int position) {
            return new FragmentContent();
        }

        @Override
        public int getCount() {
            return NUM_PAGES;
        }
    }
}
