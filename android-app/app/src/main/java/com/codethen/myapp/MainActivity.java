package com.codethen.myapp;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.text.Editable;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {

    // create: the screen is created
    // start: the screen is visible
    // resume: the screen is active (can be used)
    // pause: the screen becomes inactive (but visible)
    // stop: the screen is not visible
    // destroy: the screen is destroyed (should not use this)

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        // set the view layout
        setContentView(R.layout.activity_main);

        setupViews();
    }

    private void setupViews() {

        View button = findViewById(R.id.btn);

        button.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View view) {

                EditText field = (EditText) findViewById(R.id.email);
                String email = field.getText().toString();

                TextView infoText = (TextView) findViewById(R.id.info);
                infoText.setText("Thanks for contacting us " + email);

                View form = findViewById(R.id.form);
                form.setVisibility(View.GONE);

                infoText.setOnClickListener(new View.OnClickListener() {
                    @Override
                    public void onClick(View view) {
                        goToInfoActivity();
                    }
                });
            }
        });
    }

    private void goToInfoActivity() {

        startActivity(new Intent(this, InfoActivity.class));
    }


}
